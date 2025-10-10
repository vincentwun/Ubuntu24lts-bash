#!/bin/bash

echo "=========================================="
echo "Fcitx5 速成輸入法診斷和修復工具"
echo "=========================================="
echo ""

# 步驟 1: 檢查 fcitx5-table-extra 檔案是否存在
echo "步驟 1: 檢查安裝檔案..."
if [ -d "/usr/share/fcitx5/table" ]; then
    echo "✓ 表格目錄存在"
    echo "已安裝的表格檔案："
    ls -lh /usr/share/fcitx5/table/ | grep -E "quick|cangjie"
    
    if ls /usr/share/fcitx5/table/quick*.dict 2>/dev/null; then
        echo "✓ 速成字典檔案存在"
    else
        echo "✗ 速成字典檔案不存在，需要重新安裝"
        NEED_REINSTALL=1
    fi
else
    echo "✗ 表格目錄不存在，需要重新安裝"
    NEED_REINSTALL=1
fi

# 檢查配置檔案
echo ""
echo "檢查配置檔案..."
if [ -f "/usr/share/fcitx5/inputmethod/quick.conf" ]; then
    echo "✓ 速成配置檔案存在"
else
    echo "✗ 速成配置檔案不存在"
    NEED_REINSTALL=1
fi

echo ""
echo "=========================================="

# 步驟 2: 如果需要，重新安裝
if [ "$NEED_REINSTALL" = "1" ]; then
    echo "步驟 2: 重新編譯安裝 fcitx5-table-extra..."
    echo ""
    
    # 安裝編譯依賴
    echo "安裝編譯依賴..."
    sudo apt install -y cmake extra-cmake-modules \
        gettext libfcitx5core-dev libfcitx5config-dev \
        fcitx5-modules-dev libime-bin git
    
    # 下載原始碼
    echo ""
    echo "下載原始碼..."
    cd /tmp
    rm -rf fcitx5-table-extra
    git clone https://github.com/fcitx/fcitx5-table-extra.git
    cd fcitx5-table-extra
    
    # 編譯安裝
    echo ""
    echo "開始編譯（這可能需要幾分鐘）..."
    mkdir -p build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    make -j$(nproc)
    sudo make install
    
    # 清理
    cd /tmp
    rm -rf fcitx5-table-extra
    
    echo ""
    echo "✓ 重新安裝完成"
else
    echo "步驟 2: 檔案完整，跳過重新安裝"
fi

echo ""
echo "=========================================="

# 步驟 3: 重新啟動 Fcitx5
echo "步驟 3: 重新啟動 Fcitx5..."
killall fcitx5 2>/dev/null
echo "等待 Fcitx5 完全關閉..."
sleep 3
fcitx5 -d &
echo "等待 Fcitx5 啟動..."
sleep 2
echo "✓ Fcitx5 已重新啟動"

echo ""
echo "=========================================="

# 步驟 4: 驗證安裝
echo "步驟 4: 驗證安裝結果..."
echo ""
echo "已安裝的表格輸入法："
ls -1 /usr/share/fcitx5/table/*.dict 2>/dev/null | sed 's/.*\///' | sed 's/\.main\.dict//'

echo ""
echo "已安裝的輸入法配置："
ls -1 /usr/share/fcitx5/inputmethod/*.conf 2>/dev/null | grep -E "quick|cangjie|boshiamy|zhengma" | sed 's/.*\///'

echo "Done"