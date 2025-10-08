#!/bin/bash

# Update package list
sudo apt update

# Remove existing fcitx packages
sudo apt purge fcitx* -y

# Install fcitx5 and related packages
sudo apt install -y fcitx5 \
    fcitx5-configtool \
    fcitx5-chinese-addons \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-frontend-qt5 \
    fcitx5-config-qt

# Install additional input tables
sudo apt install -y fcitx5-table-extra

# Set fcitx5 as the default input method
im-config -n fcitx5

# Configure environment variables for fcitx5
cat > ~/.bash_profile << 'EOF'
export INPUT_METHOD="fcitx5"
export XMODIFIERS=@im=fcitx5
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
EOF

# Ensure the environment variables are loaded in new sessions
mkdir -p ~/.config/autostart/

# Add fcitx5 to startup applications
cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
