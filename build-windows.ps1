# Build Windows installer using Inno Setup
# This creates a .exe installer for Windows

param(
    [string]$Version = "1.0.0"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building Verba Windows Installer" -ForegroundColor Cyan
Write-Host "  Version: $Version" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check for Inno Setup
$InnoSetup = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
if (-not (Test-Path $InnoSetup)) {
    Write-Host "❌ Inno Setup not found!" -ForegroundColor Red
    Write-Host "   Download from: https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
    Write-Host "   Install Inno Setup 6, then run this script again" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Inno Setup found" -ForegroundColor Green

# Create Inno Setup script
$InnoScript = @"
; Verba Windows Installer Script
#define MyAppName "Verba"
#define MyAppVersion "$Version"
#define MyAppPublisher "Verba Team"
#define MyAppURL "https://github.com/OP-88/Verba-mvp"
#define MyAppExeName "verba.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE
OutputDir=.
OutputBaseFilename=Verba-Setup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "backend\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "__pycache__,*.pyc,venv,*.db"
Source: "frontend\*"; DestDir: "{app}\frontend"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "node_modules,.git,dist"
Source: "start_verba.sh"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "install-windows.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\start-verba.ps1"""; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\start-verba.ps1"""; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\install-windows.ps1"; Description: "Install dependencies"; Flags: postinstall skipifsilent shellexec
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\start-verba.ps1"""; Description: "Launch Verba"; Flags: postinstall skipifsilent nowait

[Code]
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  // Check Python
  if not RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Python\PythonCore\3.11') and
     not RegKeyExists(HKEY_CURRENT_USER, 'SOFTWARE\Python\PythonCore\3.11') then
  begin
    if MsgBox('Python 3.11+ is required but not found.' + #13#10 +
              'Would you like to download Python?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      ShellExec('open', 'https://www.python.org/downloads/', '', '', SW_SHOWNORMAL, ewNoWait, ResultCode);
    end;
    Result := False;
    Exit;
  end;
  
  // Check Node.js
  if not RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Node.js') then
  begin
    if MsgBox('Node.js 18+ is required but not found.' + #13#10 +
              'Would you like to download Node.js?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      ShellExec('open', 'https://nodejs.org/', '', '', SW_SHOWNORMAL, ewNoWait, ResultCode);
    end;
    Result := False;
    Exit;
  end;
  
  Result := True;
end;
"@

# Save script
$InnoScript | Out-File -FilePath "verba-installer.iss" -Encoding UTF8

Write-Host "`n📝 Created Inno Setup script: verba-installer.iss" -ForegroundColor Green

# Create start script for Windows
$StartScript = @'
# Start Verba on Windows
Write-Host "Starting Verba..." -ForegroundColor Cyan

$VerbaDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $VerbaDir

# Start backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$VerbaDir\backend'; .\venv\Scripts\Activate.ps1; python app.py" -WindowStyle Normal

# Wait for backend
Start-Sleep -Seconds 5

# Start frontend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$VerbaDir\frontend'; npm run dev" -WindowStyle Normal

# Wait for frontend
Start-Sleep -Seconds 5

# Open browser
Start-Process "http://localhost:5173"

Write-Host "`n✅ Verba is running!" -ForegroundColor Green
Write-Host "   Frontend: http://localhost:5173" -ForegroundColor Yellow
Write-Host "   Backend: http://localhost:8000" -ForegroundColor Yellow
Write-Host "`nClose the terminal windows to stop Verba" -ForegroundColor Cyan
'@

$StartScript | Out-File -FilePath "start-verba.ps1" -Encoding UTF8

Write-Host "📝 Created Windows start script: start-verba.ps1`n" -ForegroundColor Green

# Build installer
Write-Host "🔨 Building Windows installer..." -ForegroundColor Cyan
& $InnoSetup "verba-installer.iss"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Windows installer created!" -ForegroundColor Green
    Write-Host "`nInstaller: Verba-Setup-$Version.exe`n" -ForegroundColor Cyan
    Write-Host "To distribute:" -ForegroundColor Yellow
    Write-Host "  1. Upload Verba-Setup-$Version.exe to GitHub Releases" -ForegroundColor White
    Write-Host "  2. Users download and run the installer" -ForegroundColor White
    Write-Host "  3. Installer will check for Python and Node.js" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "`n❌ Build failed" -ForegroundColor Red
    exit 1
}
