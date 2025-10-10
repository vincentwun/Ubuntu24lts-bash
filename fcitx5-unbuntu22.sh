#!/bin/bash

echo "=========================================="
echo "完整安裝 libime 和 fcitx5-table-extra"
echo "=========================================="
echo ""

# 步驟 1: 清理舊的編譯檔案
echo "步驟 1: 清理舊的編譯檔案..."
cd /tmp
rm -rf libime fcitx5-table-extra

# 步驟 2: 安裝所有必要的依賴
echo ""
echo "步驟 2: 安裝編譯依賴..."
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    extra-cmake-modules \
    gettext \
    git \
    pkg-config \
    libfcitx5core-dev \
    libfcitx5config-dev \
    libfcitx5utils-dev \
    fcitx5-modules-dev \
    fcitx5-chinese-addons \
    libboost-iostreams-dev \
    libboost-regex-dev \
    libboost-filesystem-dev \
    zlib1g-dev

echo "✓ 依賴安裝完成"

# 步驟 3: 下載 libime
echo ""
echo "步驟 3: 下載 libime 原始碼..."
cd /tmp
git clone --depth=1 https://github.com/fcitx/libime.git
cd libime

# 步驟 4: 編譯 libime
echo ""
echo "步驟 4: 編譯 libime..."
mkdir -p build && cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_TEST=OFF \
    -DENABLE_COVERAGE=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib

echo ""
echo "開始編譯 libime（這可能需要幾分鐘）..."
make -j$(nproc)

if [ $? -ne 0 ]; then
    echo "✗ libime 編譯失敗"
    exit 1
fi

echo "✓ libime 編譯完成"

# 步驟 5: 安裝 libime
echo ""
echo "步驟 5: 安裝 libime..."
sudo make install

if [ $? -ne 0 ]; then
    echo "✗ libime 安裝失敗"
    exit 1
fi

# 更新動態連結庫快取
sudo ldconfig

echo "✓ libime 安裝完成"

# 步驟 6: 驗證 libime 安裝
echo ""
echo "步驟 6: 驗證 libime 安裝..."
echo "檢查 libIMETable 共享庫："
ls -lh /usr/lib/libIME*.so* 2>/dev/null

echo ""
echo "檢查 CMake 配置檔案："
if [ -f "/usr/lib/cmake/LibIME/LibIMEConfig.cmake" ]; then
    echo "✓ 找到 LibIMEConfig.cmake"
    ls -lh /usr/lib/cmake/LibIME/
elif [ -f "/usr/share/cmake/LibIME/LibIMEConfig.cmake" ]; then
    echo "✓ 找到 LibIMEConfig.cmake (在 /usr/share)"
    ls -lh /usr/share/cmake/LibIME/
else
    echo "⚠ 警告: 找不到 LibIMEConfig.cmake，搜尋中..."
    sudo find /usr -name "LibIME*Config.cmake" 2>/dev/null
fi

# 步驟 7: 設置 CMAKE_PREFIX_PATH
echo ""
echo "步驟 7: 設置 CMake 搜尋路徑..."
export CMAKE_PREFIX_PATH="/usr:$CMAKE_PREFIX_PATH"

# 步驟 8: 下載 fcitx5-table-extra
echo ""
echo "步驟 8: 下載 fcitx5-table-extra 原始碼..."
cd /tmp
git clone --depth=1 https://github.com/fcitx/fcitx5-table-extra.git
cd fcitx5-table-extra

# 步驟 9: 編譯 fcitx5-table-extra
echo ""
echo "步驟 9: 編譯 fcitx5-table-extra..."
mkdir -p build && cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/usr

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ CMake 配置失敗"
    echo ""
    echo "嘗試手動指定 LibIME 路徑..."
    
    # 搜尋 LibIMEConfig.cmake 位置
    LIBIME_DIR=$(sudo find /usr -name "LibIMEConfig.cmake" -exec dirname {} \; 2>/dev/null | head -1)
    
    if [ -n "$LIBIME_DIR" ]; then
        echo "找到 LibIME 配置檔案在: $LIBIME_DIR"
        cmake .. \
            -DCMAKE_INSTALL_PREFIX=/usr \
            -DCMAKE_BUILD_TYPE=Release \
            -DLibIME_DIR="$LIBIME_DIR"
    else
        echo "✗ 無法找到 LibIME 配置檔案"
        exit 1
    fi
fi

echo ""
echo "開始編譯 fcitx5-table-extra..."
make -j$(nproc)

if [ $? -ne 0 ]; then
    echo "✗ fcitx5-table-extra 編譯失敗"
    exit 1
fi

echo "✓ fcitx5-table-extra 編譯完成"

# 步驟 10: 安裝 fcitx5-table-extra
echo ""
echo "步驟 10: 安裝 fcitx5-table-extra..."
sudo make install

if [ $? -ne 0 ]; then
    echo "✗ fcitx5-table-extra 安裝失敗"
    exit 1
fi

echo "✓ fcitx5-table-extra 安裝完成"

# 步驟 11: 清理
echo ""
echo "步驟 11: 清理臨時檔案..."
cd /tmp
rm -rf libime fcitx5-table-extra
echo "✓ 清理完成"

# 步驟 12: 驗證最終安裝
echo ""
echo "=========================================="
echo "步驟 12: 驗證最終安裝..."
echo ""
echo "速成字典檔案："
ls -lh /usr/share/fcitx5/table/quick*.dict 2>/dev/null

echo ""
echo "速成配置檔案："
ls -lh /usr/share/fcitx5/inputmethod/quick*.conf 2>/dev/null

echo ""
echo "所有表格輸入法："
ls -1 /usr/share/fcitx5/table/*.dict 2>/dev/null | sed 's/.*\///' | sed 's/\.main\.dict//'

# 步驟 13: 重新啟動 Fcitx5
echo ""
echo "=========================================="
echo "步驟 13: 重新啟動 Fcitx5..."
killall fcitx5 2>/dev/null
sleep 3
fcitx5 -d &
sleep 2
echo "✓ Fcitx5 已重新啟動"

echo ""
echo "=========================================="
echo "✓✓✓ 安裝完全成功！✓✓✓"
echo "=========================================="

 git add -A && git commit -m '22' && git push origin main