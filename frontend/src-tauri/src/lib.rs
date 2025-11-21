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
  #[cfg(target_os = "windows")]
  let python_cmd = "python";
  
  #[cfg(not(target_os = "windows"))]
  let python_cmd = "python3";

  // Find backend directory - handle both bundled paths
  let mut backend_dir = app_dir.join("backend");
  
  // If backend not found, try the _up_/_up_/backend path (from resources bundling)
  if !backend_dir.exists() {
    backend_dir = app_dir.join("_up_").join("_up_").join("backend");
  }
  
  // If still not found, try /usr/lib/Verba path (system install)
  if !backend_dir.exists() {
    backend_dir = std::path::PathBuf::from("/usr/lib/Verba/_up_/_up_/backend");
  }
  
  // Use system Python instead of bundled venv for cross-distro compatibility
  // Dependencies are installed via package manager (DEB/RPM dependencies)
  let app_py = backend_dir.join("app.py");

  eprintln!("Starting backend from: {:?}", backend_dir);
  eprintln!("Python command: {}", python_cmd);
  eprintln!("App.py path: {:?}", app_py);

  Command::new(python_cmd)
    .arg(&app_py)
    .current_dir(&backend_dir)
    .stdout(std::process::Stdio::inherit())
    .stderr(std::process::Stdio::inherit())
    .spawn()
    .expect("Failed to start backend server")
}
