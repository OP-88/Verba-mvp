#!/bin/bash
# Verba Network Deployment Script
# Allows access from other devices on your local network

echo "🌐 Starting Verba for network access..."
echo ""

# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

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

# Start backend (already listens on 0.0.0.0:8000)
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
    echo "   ✅ Backend running at http://0.0.0.0:8000"
else
    echo "   ❌ Backend failed to start. Check verba-backend.log"
    exit 1
fi

# Start frontend with network host
echo "🎨 Starting frontend server (network mode)..."
cd frontend
VITE_API_URL=http://${LOCAL_IP}:8000 npm run dev -- --host > ../verba-frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo "   Frontend PID: $FRONTEND_PID"
sleep 3

# Check if frontend started
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "   ✅ Frontend running on all interfaces"
else
    echo "   ⚠️  Frontend may still be starting..."
fi

echo ""
echo "=========================================="
echo "✅ Verba is accessible on your network!"
echo "=========================================="
echo ""
echo "🖥️  LOCAL ACCESS:"
echo "   http://localhost:5173"
echo ""
echo "📱 NETWORK ACCESS (from other devices):"
echo "   http://${LOCAL_IP}:5173"
echo ""
echo "🔧 Backend API:"
echo "   Local:   http://localhost:8000"
echo "   Network: http://${LOCAL_IP}:8000"
echo ""
echo "📋 Logs:"
echo "   Backend:  tail -f verba-backend.log"
echo "   Frontend: tail -f verba-frontend.log"
echo ""
echo "🛑 To stop Verba:"
echo "   ./stop_verba.sh"
echo ""
echo "⚠️  FIREWALL NOTE:"
echo "   If you can't connect from other devices, open ports:"
echo "   sudo firewall-cmd --add-port=5173/tcp --add-port=8000/tcp"
echo "   (or temporarily: sudo firewall-cmd --add-port=5173/tcp --add-port=8000/tcp --permanent)"
echo ""

# Open browser (Linux)
if command -v xdg-open > /dev/null; then
    sleep 2
    xdg-open http://localhost:5173 2>/dev/null &
fi

# Keep script running to show it's active
echo "Press Ctrl+C to stop monitoring (servers will keep running)"
tail -f verba-backend.log verba-frontend.log
