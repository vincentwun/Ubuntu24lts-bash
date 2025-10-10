#!/bin/bash

echo "=========================================="
echo "安裝 libime 和 fcitx5-table-extra"
echo "=========================================="
echo ""

# 步驟 1: 安裝基本編譯工具
echo "步驟 1: 安裝編譯依賴..."
sudo apt update
sudo apt install -y build-essential cmake extra-cmake-modules \
    gettext git pkg-config

# 步驟 2: 安裝 fcitx5 相關開發套件
echo ""
echo "步驟 2: 安裝 fcitx5 開發套件..."
sudo apt install -y libfcitx5core-dev libfcitx5config-dev \
    fcitx5-modules-dev fcitx5-chinese-addons

# 步驟 3: 編譯安裝 libime
echo ""
echo "步驟 3: 編譯安裝 libime..."
cd /tmp
rm -rf libime
git clone https://github.com/fcitx/libime.git
cd libime

# 建立並進入 build 目錄
mkdir -p build && cd build

# 配置編譯選項
cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_TEST=OFF \
    -DENABLE_COVERAGE=OFF

# 編譯（使用所有 CPU 核心）
echo "編譯 libime（這可能需要幾分鐘）..."
make -j$(nproc)

# 安裝
echo "安裝 libime..."
sudo make install

# 更新動態連結庫快取
sudo ldconfig

echo "✓ libime 安裝完成"

# 步驟 4: 編譯安裝 fcitx5-table-extra
echo ""
echo "步驟 4: 編譯安裝 fcitx5-table-extra..."
cd /tmp
rm -rf fcitx5-table-extra
git clone https://github.com/fcitx/fcitx5-table-extra.git
cd fcitx5-table-extra

# 建立並進入 build 目錄
mkdir -p build && cd build

# 配置編譯選項
cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release

# 編譯
echo "編譯 fcitx5-table-extra..."
make -j$(nproc)

# 安裝
echo "安裝 fcitx5-table-extra..."
sudo make install

echo "✓ fcitx5-table-extra 安裝完成"

# 清理
cd /tmp
rm -rf libime fcitx5-table-extra

# 步驟 5: 驗證安裝
echo ""
echo "=========================================="
echo "步驟 5: 驗證安裝..."
echo ""
echo "已安裝的 libime 檔案："
ls -lh /usr/lib/libIME*.so* 2>/dev/null || echo "⚠ 警告: libime 共享庫未找到"

echo ""
echo "已安裝的速成表格檔案："
ls -lh /usr/share/fcitx5/table/quick*.dict 2>/dev/null || echo "⚠ 警告: 速成字典未找到"

echo ""
echo "已安裝的速成配置檔："
ls -lh /usr/share/fcitx5/inputmethod/quick*.conf 2>/dev/null || echo "⚠ 警告: 速成配置未找到"

echo "✓ "