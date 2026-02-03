#!/bin/bash
set -e

echo "[$(date)] Starting VNC setup..." | tee /tmp/vnc.log

# Kill any existing sessions
vncserver -kill :1 2>/dev/null || true
pkill -9 websockify 2>/dev/null || true
sleep 1

# Start VNC server
echo "[$(date)] Starting VNC server..." | tee -a /tmp/vnc.log
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no -rfbport 5901 -SecurityTypes None 2>&1 | tee -a /tmp/vnc.log

# Wait for VNC to be ready
sleep 2

# Check VNC status
if ! pgrep -x "Xtigervnc" > /dev/null; then
    echo "[$(date)] ERROR: VNC server failed to start" | tee -a /tmp/vnc.log
    exit 1
fi

# Start noVNC websocket proxy in background
echo "[$(date)] Starting noVNC/websockify..." | tee -a /tmp/vnc.log
if [ -d "/usr/share/novnc" ]; then
    websockify -D --web=/usr/share/novnc/ 0.0.0.0:6080 localhost:5901 >> /tmp/vnc.log 2>&1
else
    websockify -D 0.0.0.0:6080 localhost:5901 >> /tmp/vnc.log 2>&1
fi

# Verify websockify started
sleep 1
if pgrep -f "websockify" > /dev/null; then
    echo "[$(date)] ✓ VNC server started on :1 (port 5901)" | tee -a /tmp/vnc.log
    echo "[$(date)] ✓ noVNC web interface available on port 6080" | tee -a /tmp/vnc.log
    echo "[$(date)] Open: http://localhost:6080/vnc.html" | tee -a /tmp/vnc.log
else
    echo "[$(date)] WARNING: websockify may not have started" | tee -a /tmp/vnc.log
fi

echo "[$(date)] Setup complete. Check /tmp/vnc.log for details" | tee -a /tmp/vnc.log
