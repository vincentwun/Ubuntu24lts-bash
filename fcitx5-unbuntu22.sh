# 安裝缺少的依賴
sudo apt update
sudo apt install -y libzstd-dev

# 清理舊的 build 目錄
cd /tmp/libime
rm -rf build

# 重新編譯
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DENABLE_TEST=OFF
make -j$(nproc)
sudo make install
sudo ldconfig

# 繼續安裝 fcitx5-table-extra
cd /tmp
rm -rf fcitx5-table-extra
git clone --depth=1 https://github.com/fcitx/fcitx5-table-extra.git
cd fcitx5-table-extra
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
cmake --build .
sudo cmake --install .

# 驗證安裝
ls -lh /usr/share/fcitx5/table/quick*.dict
ls -lh /usr/share/fcitx5/inputmethod/quick*.conf

# 重啟 fcitx5
pkill -9 fcitx5
sleep 2
fcitx5 -d &
