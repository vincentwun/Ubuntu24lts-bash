#!/bin/bash

sudo apt update

# Install all fcitx5 packages
sudo apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-chinese-addons \
    fcitx5-frontend-gtk2 \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-frontend-qt5 \
    libgtk2.0-bin \
    libgtk-3-bin

# Compile and install libime
cd /tmp
rm -rf libime
git clone --depth=1 https://github.com/fcitx/libime.git
cd libime
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DENABLE_TEST=OFF -DCMAKE_INSTALL_LIBDIR=lib
make -j$(nproc)
sudo make install
sudo ldconfig

# Compile and install fcitx5-table-extra
cd /tmp
rm -rf fcitx5-table-extra
git clone --depth=1 https://github.com/fcitx/fcitx5-table-extra.git
cd fcitx5-table-extra
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install

cd /tmp
rm -rf libime fcitx5-table-extra

# Update GTK immodule cache
sudo /usr/lib/x86_64-linux-gnu/libgtk2.0-0/gtk-query-immodules-2.0 --update-cache 2>/dev/null
sudo /usr/lib/x86_64-linux-gnu/libgtk-3-0/gtk-query-immodules-3.0 --update-cache 2>/dev/null

# For GTK 4
if [ -f "/usr/lib/x86_64-linux-gnu/gtk-4.0/4.0.0/immodules/im-fcitx5.so" ]; then
    sudo mkdir -p /usr/lib/x86_64-linux-gnu/gtk-4.0/4.0.0
    sudo /usr/lib/x86_64-linux-gnu/libgtk-4-1/gtk-query-immodules-4.0 > /tmp/immodules.cache 2>/dev/null
    sudo mv /tmp/immodules.cache /usr/lib/x86_64-linux-gnu/gtk-4.0/4.0.0/immodules.cache 2>/dev/null
fi

# Backup and clean environment variables
if [ -f /etc/environment ]; then
    sudo cp /etc/environment /etc/environment.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f ~/.xprofile ]; then
    cp ~/.xprofile ~/.xprofile.backup.$(date +%Y%m%d_%H%M%S)
fi

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

# Write correct environment variables
sudo tee -a /etc/environment > /dev/null << 'EOF'

# Fcitx5 Input Method
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF

cat > ~/.xprofile << 'EOF'
# Fcitx5 Input Method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus

fcitx5 -d &
EOF

chmod +x ~/.xprofile

im-config -n fcitx5

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

killall fcitx5 2>/dev/null
sleep 3

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx

fcitx5 -d &
sleep 2
