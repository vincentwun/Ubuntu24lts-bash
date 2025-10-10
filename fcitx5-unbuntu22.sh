#!/bin/bash

# Update package list
sudo apt update

# Remove existing fcitx packages
sudo apt purge fcitx* -y

# Install fcitx5 and related packages
sudo apt install -y fcitx5 \
    fcitx5-config-qt \
    fcitx5-chinese-addons \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-frontend-qt5

# Install build dependencies
sudo apt install -y cmake extra-cmake-modules \
    gettext libfcitx5core-dev libfcitx5config-dev \
    fcitx5-modules-dev libime-bin git

# Download source code
cd /tmp
git clone https://github.com/fcitx/fcitx5-table-extra.git
cd fcitx5-table-extra

# Compile and install
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install

# Clean up
cd /tmp
rm -rf fcitx5-table-extra

# Set fcitx5 as default
im-config -n fcitx5

# Configure environment variables
sudo tee -a /etc/environment > /dev/null << 'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF

# Add to startup
mkdir -p ~/.config/autostart/
cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/

echo "Done! Please restart your computer to apply the changes."