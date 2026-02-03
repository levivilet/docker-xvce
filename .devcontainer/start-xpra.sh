#!/bin/bash

# Alternative using Xpra - more modern than VNC
# Install with: sudo apt-get install -y xpra xserver-xorg-video-dummy

echo "Starting Xpra server..."
xpra start :100 \
    --bind-tcp=0.0.0.0:14500 \
    --html=on \
    --start=xfce4-session \
    --daemon=no \
    --no-notifications

echo "Xpra started!"
echo "Connect via browser: http://localhost:14500"
echo "Or use Xpra client: xpra attach tcp://localhost:14500"
