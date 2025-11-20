# Verba Windows Installer
# Run with: powershell -ExecutionPolicy Bypass -File install-windows.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verba - Offline AI Meeting Assistant" -ForegroundColor Cyan
Write-Host "  Windows Installer v1.0.0" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Warning: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "   Some installations may require admin privileges`n" -ForegroundColor Yellow
}

# Check Python
Write-Host "🔍 Checking Python..." -ForegroundColor Green
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python 3\.([0-9]+)") {
        $minorVersion = [int]$Matches[1]
        if ($minorVersion -ge 11) {
            Write-Host "✅ $pythonVersion found`n" -ForegroundColor Green
        } else {
            Write-Host "❌ Python 3.11+ required. Found: $pythonVersion" -ForegroundColor Red
            Write-Host "   Download from: https://www.python.org/downloads/`n" -ForegroundColor Yellow
            exit 1
        }
    }
} catch {
    Write-Host "❌ Python not found" -ForegroundColor Red
    Write-Host "   Download Python 3.11+ from: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "   Make sure to check 'Add Python to PATH' during installation`n" -ForegroundColor Yellow
    exit 1
}

# Check Node.js
Write-Host "🔍 Checking Node.js..." -ForegroundColor Green
try {
    $nodeVersion = node --version 2>&1
    if ($nodeVersion -match "v([0-9]+)") {
        $majorVersion = [int]$Matches[1]
        if ($majorVersion -ge 18) {
            Write-Host "✅ Node.js $nodeVersion found`n" -ForegroundColor Green
        } else {
            Write-Host "❌ Node.js 18+ required. Found: $nodeVersion" -ForegroundColor Red
            Write-Host "   Download from: https://nodejs.org/`n" -ForegroundColor Yellow
            exit 1
        }
    }
} catch {
    Write-Host "❌ Node.js not found" -ForegroundColor Red
    Write-Host "   Download Node.js 18+ from: https://nodejs.org/`n" -ForegroundColor Yellow
    exit 1
}

# Check ffmpeg
Write-Host "🔍 Checking ffmpeg..." -ForegroundColor Green
try {
    $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Host "✅ ffmpeg found`n" -ForegroundColor Green
} catch {
    Write-Host "❌ ffmpeg not found" -ForegroundColor Red
    Write-Host "   Download from: https://www.gyan.dev/ffmpeg/builds/" -ForegroundColor Yellow
    Write-Host "   1. Download 'ffmpeg-release-essentials.zip'" -ForegroundColor Yellow
    Write-Host "   2. Extract and add 'bin' folder to your PATH`n" -ForegroundColor Yellow
    exit 1
}

# Setup Backend
Write-Host "📦 Setting up backend..." -ForegroundColor Green
Set-Location backend

if (-not (Test-Path "venv")) {
    python -m venv venv
}

.\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Backend installation failed" -ForegroundColor Red
    exit 1
}

Set-Location ..
Write-Host "✅ Backend setup complete`n" -ForegroundColor Green

# Setup Frontend
Write-Host "📦 Setting up frontend..." -ForegroundColor Green
Set-Location frontend
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Frontend installation failed" -ForegroundColor Red
    exit 1
}

Set-Location ..
Write-Host "✅ Frontend setup complete`n" -ForegroundColor Green

# Create start script
Write-Host "📝 Creating start script..." -ForegroundColor Green
$startScript = @'
# Start Verba
Write-Host "Starting Verba..." -ForegroundColor Cyan

# Start backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; .\venv\Scripts\Activate.ps1; python app.py"

# Wait a bit for backend to start
Start-Sleep -Seconds 3

# Start frontend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd frontend; npm run dev"

Write-Host "`n✅ Verba is starting!" -ForegroundColor Green
Write-Host "   Backend: http://localhost:8000" -ForegroundColor Yellow
Write-Host "   Frontend: http://localhost:5173`n" -ForegroundColor Yellow
Write-Host "Press Ctrl+C in the terminal windows to stop Verba" -ForegroundColor Cyan
'@

$startScript | Out-File -FilePath "start-verba.ps1" -Encoding UTF8

Write-Host "✅ Installation complete!`n" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  To start Verba, run:" -ForegroundColor White
Write-Host "  powershell -File start-verba.ps1" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan
