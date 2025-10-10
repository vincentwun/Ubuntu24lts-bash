#!/bin/bash

# Backup existing settings
if [ -f /etc/environment ]; then
    sudo cp /etc/environment /etc/environment.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.xprofile ]; then
    cp ~/.xprofile ~/.xprofile.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
fi

# Clean incorrect environment variables
sudo sed -i '/GTK_IM_MODULE/d' /etc/environment 2>/dev/null
sudo sed -i '/QT_IM_MODULE/d' /etc/environment 2>/dev/null
sudo sed -i '/XMODIFIERS/d' /etc/environment 2>/dev/null
sudo sed -i '/SDL_IM_MODULE/d' /etc/environment 2>/dev/null
sudo sed -i '/GLFW_IM_MODULE/d' /etc/environment 2>/dev/null

sed -i '/GTK_IM_MODULE/d' ~/.xprofile 2>/dev/null
sed -i '/QT_IM_MODULE/d' ~/.xprofile 2>/dev/null
sed -i '/XMODIFIERS/d' ~/.xprofile 2>/dev/null
sed -i '/SDL_IM_MODULE/d' ~/.xprofile 2>/dev/null
sed -i '/INPUT_METHOD/d' ~/.xprofile 2>/dev/null

sed -i '/GTK_IM_MODULE/d' ~/.bashrc 2>/dev/null
sed -i '/QT_IM_MODULE/d' ~/.bashrc 2>/dev/null
sed -i '/XMODIFIERS/d' ~/.bashrc 2>/dev/null

# Write correct environment variables to /etc/environment
sudo tee -a /etc/environment > /dev/null << 'EOF'

# Fcitx5 Input Method
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF

# Create ~/.xprofile
cat > ~/.xprofile << 'EOF'
# Fcitx5 Input Method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus

# Start Fcitx5
fcitx5 -d &
EOF

chmod +x ~/.xprofile

# Configure im-config
im-config -n fcitx5

# Setup autostart
mkdir -p ~/.config/autostart/
cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/ 2>/dev/null || \
cat > ~/.config/autostart/fcitx5.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx 5
Exec=fcitx5 -d
Terminal=false
Categories=System;Utility;
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

# Restart Fcitx5
killall fcitx5 2>/dev/null
sleep 3

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx

fcitx5 -d &
sleep 2
