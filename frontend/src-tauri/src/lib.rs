use std::process::{Command, Child};
use std::sync::Mutex;
use tauri::Manager;

struct BackendProcess(Mutex<Option<Child>>);

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
  tauri::Builder::default()
    .setup(|app| {
      // Start Python backend
      let backend_child = start_backend(app.path().app_data_dir().unwrap());
      app.manage(BackendProcess(Mutex::new(Some(backend_child))));

      // Configure webkit to allow microphone access on Linux
      #[cfg(target_os = "linux")]
      {
        if let Some(window) = app.get_webview_window("main") {
          let _ = window.with_webview(move |webview| {
            #[cfg(target_os = "linux")]
            {
              use webkit2gtk::WebViewExt;
              use webkit2gtk::PermissionRequestExt;
              unsafe {
                let wv = &webview.inner().clone();
                wv.connect_permission_request(move |_, request| {
                  request.allow();
                  true
                });
              }
            }
          });
        }
      }

      if cfg!(debug_assertions) {
        app.handle().plugin(
          tauri_plugin_log::Builder::default()
            .level(log::LevelFilter::Info)
            .build(),
        )?;
      }
      Ok(())
    })
    .on_window_event(|_window, event| {
      if let tauri::WindowEvent::Destroyed = event {
        // Stop backend when window closes
        if let Some(backend) = _window.state::<BackendProcess>().0.lock().unwrap().as_mut() {
          let _ = backend.kill();
        }
      }
    })
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}

fn start_backend(app_dir: std::path::PathBuf) -> Child {
  // Find backend directory - handle both bundled paths
  let mut backend_dir = app_dir.join("backend");
  
  // If backend not found, try the _up_/_up_/backend path (from resources bundling)
  if !backend_dir.exists() {
    backend_dir = app_dir.join("_up_").join("_up_").join("backend");
  }
  
  // On Linux, try system install path if not found
  #[cfg(target_os = "linux")]
  if !backend_dir.exists() {
    backend_dir = std::path::PathBuf::from("/usr/lib/Verba/_up_/_up_/backend");
  }
  
  let app_py = backend_dir.join("app.py");

  eprintln!("Starting backend from: {:?}", backend_dir);
  eprintln!("App.py path: {:?}", app_py);

  // On Windows and macOS, use bundled venv
  // On Linux, use system Python (installed via package manager)
  #[cfg(target_os = "windows")]
  let python_cmd = {
    let venv_python = backend_dir.join("venv").join("Scripts").join("python.exe");
    if venv_python.exists() {
      eprintln!("Using bundled venv: {:?}", venv_python);
      venv_python.to_str().unwrap().to_string()
    } else {
      eprintln!("WARNING: Bundled venv not found, trying system Python");
      "python".to_string()
    }
  };

  #[cfg(target_os = "macos")]
  let python_cmd = {
    let venv_python = backend_dir.join("venv").join("bin").join("python3");
    if venv_python.exists() {
      eprintln!("Using bundled venv: {:?}", venv_python);
      venv_python.to_str().unwrap().to_string()
    } else {
      eprintln!("WARNING: Bundled venv not found, trying system Python");
      "python3".to_string()
    }
  };

  #[cfg(target_os = "linux")]
  let python_cmd = {
    eprintln!("Using system Python on Linux");
    "python3".to_string()
  };

  eprintln!("Python command: {}", python_cmd);

  Command::new(&python_cmd)
    .arg(&app_py)
    .current_dir(&backend_dir)
    .stdout(std::process::Stdio::inherit())
    .stderr(std::process::Stdio::inherit())
    .spawn()
    .expect("Failed to start backend server")
}
