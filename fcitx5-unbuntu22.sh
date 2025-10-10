# 步驟 1: 安裝必要套件
sudo apt update
sudo apt install -y \
    fcitx5 \
    fcitx5-chinese-addons \
    fcitx5-config-qt \
    fcitx5-frontend-gtk2 \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-frontend-qt5 \
    cmake \
    extra-cmake-modules \
    gettext \
    git \
    build-essential \
    pkg-config \
    libfcitx5core-dev \
    libfcitx5config-dev \
    libfcitx5utils-dev \
    fcitx5-modules-dev \
    libboost-all-dev

# 步驟 2: 編譯安裝 libime
cd /tmp
rm -rf libime
git clone --depth=1 https://github.com/fcitx/libime.git
cd libime
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DENABLE_TEST=OFF
make -j$(nproc)
sudo make install
sudo ldconfig

# 步驟 3: 編譯安裝 fcitx5-table-extra
cd /tmp
rm -rf fcitx5-table-extra
git clone --depth=1 https://github.com/fcitx/fcitx5-table-extra.git
cd fcitx5-table-extra
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
cmake --build .
sudo cmake --install .

# 步驟 4: 重啟 fcitx5
pkill -9 fcitx5
sleep 2
fcitx5 -d &

# 步驟 5: 驗證安裝
ls -lh /usr/share/fcitx5/table/quick*.dict
ls -lh /usr/share/fcitx5/inputmethod/quick*.conf
