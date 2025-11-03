#!/bin/bash
# Stop Verba servers

echo "🛑 Stopping Verba..."

# Kill backend
pkill -f "python app.py" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ Backend stopped"
else
    echo "   ℹ️  Backend was not running"
fi

# Kill frontend
pkill -f "vite" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ Frontend stopped"
else
    echo "   ℹ️  Frontend was not running"
fi

echo ""
echo "✅ Verba stopped successfully"
