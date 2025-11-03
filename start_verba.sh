#!/bin/bash
# Verba Local Deployment Script

echo "🚀 Starting Verba locally..."
echo ""

# Check if we're in the right directory
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Error: Run this script from the Verba-mvp root directory"
    exit 1
fi

# Kill any existing processes
echo "🧹 Cleaning up existing processes..."
pkill -f "python app.py" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 2

# Start backend
echo "🔧 Starting backend server..."
cd backend
source venv/bin/activate
python app.py > ../verba-backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo "   Backend PID: $BACKEND_PID"
sleep 3

# Check if backend started
if curl -s http://localhost:8000/api/status > /dev/null 2>&1; then
    echo "   ✅ Backend running at http://localhost:8000"
else
    echo "   ❌ Backend failed to start. Check verba-backend.log"
    exit 1
fi

# Start frontend
echo "🎨 Starting frontend server..."
cd frontend
npm run dev > ../verba-frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo "   Frontend PID: $FRONTEND_PID"
sleep 3

# Check if frontend started
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "   ✅ Frontend running at http://localhost:5173"
else
    echo "   ⚠️  Frontend may still be starting..."
fi

echo ""
echo "=========================================="
echo "✅ Verba is running locally!"
echo "=========================================="
echo ""
echo "📱 Open in browser: http://localhost:5173"
echo "🔧 Backend API:     http://localhost:8000"
echo ""
echo "📋 Logs:"
echo "   Backend:  tail -f verba-backend.log"
echo "   Frontend: tail -f verba-frontend.log"
echo ""
echo "🛑 To stop Verba:"
echo "   ./stop_verba.sh"
echo "   (or press Ctrl+C and run: pkill -f 'python app.py' && pkill -f 'vite')"
echo ""

# Open browser (Linux)
if command -v xdg-open > /dev/null; then
    sleep 2
    xdg-open http://localhost:5173 2>/dev/null &
fi

# Keep script running to show it's active
echo "Press Ctrl+C to stop monitoring (servers will keep running)"
tail -f verba-backend.log verba-frontend.log
