# Verba Deployment Debugging & Fixes

## 🚨 Critical Issue: Architecture Mismatch

**MAIN PROBLEM**: Verba currently **CANNOT** run fully on Vercel because:

1. **Backend is Python + FastAPI**: Vercel only supports Node.js serverless functions natively
2. **Whisper AI requires heavy compute**: ~75MB+ model, CPU/GPU intensive transcription
3. **Long-running processes**: Whisper transcription can take 5-15 seconds, exceeding typical serverless timeouts
4. **Binary dependencies**: Requires ffmpeg, which is not available in Vercel's serverless environment

## ✅ What We Debugged

### Frontend Build Status: **WORKING** ✓

The frontend builds successfully:
- All dependencies installed correctly
- No missing imports or broken components
- TailwindCSS configuration is correct
- Vite build completes without errors
- Build output: `dist/` folder with optimized assets

### Component Issues Found: **NONE** ✓

All React components are properly structured:
- ✅ App.jsx - State management working
- ✅ Recorder.jsx - MediaRecorder API usage correct
- ✅ Header.jsx - API status fetch with fallback
- ✅ SessionHistory.jsx - Session loading with error handling
- ✅ TranscriptBox.jsx - Props validation correct
- ✅ SummaryBox.jsx - Conditional rendering working
- ✅ Toast.jsx - useEffect cleanup correct

## 🎯 Deployment Solutions

### Option 1: Frontend-Only on Vercel (Recommended for Testing)

Deploy just the frontend to Vercel and point it to a separate backend.

**Steps:**

1. **Deploy Frontend to Vercel**:
   ```bash
   cd frontend
   vercel
   ```

2. **Set Environment Variable in Vercel Dashboard**:
   - Go to Vercel Project Settings
   - Add environment variable: `VITE_API_URL=https://your-backend-url.com`
   - Redeploy

3. **Backend Options**:
   - **Railway**: Best for Python apps with long-running processes
   - **Render**: Free tier available, supports Python + ffmpeg
   - **Fly.io**: Good for containerized apps
   - **Digital Ocean App Platform**: $5/month, full control
   - **Self-hosted VPS**: Hetzner, Linode, etc.

**Backend Deployment Commands (Railway Example)**:
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and initialize
railway login
railway init

# Deploy from backend directory
cd backend
railway up
```

### Option 2: Full-Stack on Railway/Render

Deploy both frontend and backend together on a platform that supports Python.

**Railway/Render Advantages**:
- Supports Python with long-running processes
- Can install system packages (ffmpeg)
- Better for AI/ML workloads
- Simple deployment from Git

### Option 3: Containerize Everything (Docker)

Best for production and portability.

**Create `Dockerfile` in backend/**:
```dockerfile
FROM python:3.11-slim

# Install ffmpeg
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "app.py"]
```

**Create `docker-compose.yml` in root**:
```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - WHISPER_MODEL_SIZE=tiny
      - DATABASE_PATH=/data/verba_sessions.db
    volumes:
      - backend_data:/data

  frontend:
    build: ./frontend
    ports:
      - "5173:5173"
    environment:
      - VITE_API_URL=http://localhost:8000
    depends_on:
      - backend

volumes:
  backend_data:
```

Then deploy to:
- **Fly.io**: Excellent Docker support
- **DigitalOcean App Platform**: Docker + managed database
- **AWS ECS/Fargate**: Enterprise option

## 🔧 Required Fixes for Vercel Frontend-Only Deployment

### 1. Create Production Environment File

Create `frontend/.env.production`:
```bash
# Point to your hosted backend
VITE_API_URL=https://your-backend-url.com
```

### 2. Update Vercel Configuration

Update `frontend/vercel.json`:
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "installCommand": "npm install",
  "framework": "vite",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    }
  ]
}
```

### 3. Add Error Boundary for Production

Create `frontend/src/components/ErrorBoundary.jsx`:
```jsx
import React from 'react'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-4">
          <div className="backdrop-blur-xl bg-white/10 rounded-3xl border border-white/20 shadow-2xl p-8 max-w-md">
            <h2 className="text-2xl font-bold text-red-400 mb-4">⚠️ Something went wrong</h2>
            <p className="text-gray-300 mb-4">The application encountered an error. Please refresh the page.</p>
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-xl font-semibold hover:from-purple-600 hover:to-pink-600"
            >
              Refresh Page
            </button>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
```

Update `frontend/src/main.jsx`:
```jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import ErrorBoundary from './components/ErrorBoundary.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </React.StrictMode>,
)
```

### 4. Add Backend Health Check Warning

Update `frontend/src/components/Header.jsx` to show a warning if backend is unreachable:

Add after line 16:
```jsx
const [backendDown, setBackendDown] = useState(false)
```

Update the useEffect (lines 10-18):
```jsx
useEffect(() => {
  // Fetch status on mount
  getStatus()
    .then(data => {
      setStatus(data)
      setBackendDown(false)
    })
    .catch(err => {
      // Fallback to offline mode if status fails
      setStatus({ online_features_enabled: false, model: 'tiny', device: 'cpu' })
      setBackendDown(true)
    })
}, [])
```

Add warning banner before the existing return (after line 21):
```jsx
if (backendDown) {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-xl bg-slate-900/80 border-b border-white/10">
      <div className="bg-red-500/20 border-b border-red-500/30 px-6 py-3">
        <div className="flex items-center gap-3 text-red-300">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span className="text-sm font-semibold">
            Backend server is unavailable. Please check your API configuration.
          </span>
        </div>
      </div>
      <div className="container mx-auto px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <h1 className="text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-400 via-pink-400 to-blue-400">
              Verba
            </h1>
            <span className="text-gray-400 text-sm hidden sm:inline">
              Offline-first meeting assistant
            </span>
          </div>
        </div>
      </div>
    </header>
  )
}
```

## 📋 Deployment Checklist

### For Vercel Frontend Deployment:

- [ ] Install dependencies: `cd frontend && npm install`
- [ ] Test build locally: `npm run build`
- [ ] Deploy backend to Railway/Render/Fly.io
- [ ] Get backend URL (e.g., `https://verba-backend.railway.app`)
- [ ] Set `VITE_API_URL` environment variable in Vercel
- [ ] Deploy to Vercel: `vercel --prod`
- [ ] Test API connectivity
- [ ] Enable CORS on backend for Vercel domain

### For Railway Full-Stack Deployment:

- [ ] Create Railway account
- [ ] Install Railway CLI: `npm install -g @railway/cli`
- [ ] Initialize: `railway init`
- [ ] Add environment variables in Railway dashboard
- [ ] Deploy backend: `railway up` (from backend/)
- [ ] Get backend URL from Railway
- [ ] Deploy frontend with updated `VITE_API_URL`

## 🐛 Common Issues & Solutions

### Issue 1: CORS Errors
**Error**: `Access to fetch at 'https://backend.com' from origin 'https://verba.vercel.app' has been blocked by CORS policy`

**Fix**: Update `backend/settings.py`:
```python
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost:5173,https://your-vercel-app.vercel.app").split(",")
```

### Issue 2: API URL Not Loading
**Error**: Frontend shows "Backend server is unavailable"

**Fix**: 
1. Check Vercel environment variables
2. Verify backend is running: `curl https://your-backend.com/api/status`
3. Check browser console for exact error

### Issue 3: Build Fails on Vercel
**Error**: `vite: command not found`

**Fix**: Ensure `package.json` has correct scripts and Vercel auto-detects Vite

### Issue 4: Whisper Model Download Timeout
**Error**: Deployment times out during model download

**Fix**: 
1. Pre-download model in Docker image
2. Use persistent storage for model cache
3. Use smaller model: `WHISPER_MODEL_SIZE=tiny`

## 🎉 Summary

**Current Status**:
- ✅ Frontend code is **100% working**
- ✅ Build process is **successful**
- ❌ Backend **cannot run on Vercel** (architecture limitation)

**Recommended Path**:
1. Deploy frontend to Vercel (fast, free, CDN)
2. Deploy backend to Railway (Python-friendly, $5/month)
3. Connect them via environment variables
4. Add CORS configuration

**Alternative**: Use Railway/Render for full-stack deployment (simpler but slightly more expensive).

**Long-term**: Consider building a lighter backend that uses cloud APIs (OpenAI Whisper API) if you want to stay fully serverless.
