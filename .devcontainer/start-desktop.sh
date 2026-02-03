#!/bin/bash

# Kill any existing VNC sessions
vncserver -kill :1 2>/dev/null || true
pkill -9 websockify 2>/dev/null || true

# Wait a moment for cleanup
sleep 2

# Start VNC server
echo "Starting VNC server..."
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no -rfbport 5901 -SecurityTypes None -dpi 96

# Wait for VNC to be ready
sleep 3

# Check if noVNC web files exist
if [ -d "/usr/share/novnc" ]; then
    echo "Starting noVNC with websockify..."
    websockify -D --web=/usr/share/novnc/ 0.0.0.0:6080 localhost:5901
elif [ -d "/usr/share/novnc/utils" ]; then
    echo "Starting noVNC (alternative path)..."
    /usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:6080 &
else
    echo "WARNING: noVNC files not found, using websockify only"
    websockify -D 0.0.0.0:6080 localhost:5901
fi

# Verify processes
sleep 2
if pgrep -x "Xtigervnc" > /dev/null; then
    echo "✓ VNC server is running on :1 (port 5901)"
else
    echo "✗ VNC server failed to start"
    exit 1
fi

if pgrep -f "websockify" > /dev/null; then
    echo "✓ noVNC web interface available on port 6080"
    echo "  Open: http://localhost:6080/"
else
    echo "✗ noVNC/websockify failed to start"
    exit 1
fi

echo ""
echo "To stop: vncserver -kill :1 && pkill websockify"
