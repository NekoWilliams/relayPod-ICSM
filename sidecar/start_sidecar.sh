#!/bin/bash

# NFDとsidecarを起動するスクリプト

set -e

echo "Starting NFD and sidecar..."

# ログディレクトリを作成（存在しない場合）
mkdir -p /var/log/sidecar
chmod 755 /var/log/sidecar

# NFDの設定ディレクトリを作成
mkdir -p /run/nfd
chmod 755 /run/nfd

# NFDを起動
echo "Starting NFD..."
nfd > /var/log/sidecar/nfd.log 2>&1 &
NFD_PID=$!
echo "NFD started with PID: $NFD_PID"

# NFDの起動を待つ
echo "Waiting for NFD to start..."
sleep 10

# NFDの状態を確認（プロセスの存在とUnixソケットの存在を確認）
echo "Checking NFD status..."
NFD_RUNNING=false
for i in {1..10}; do
    # NFDプロセスの存在を確認
    if pgrep -f "^nfd" > /dev/null 2>&1; then
        # Unixソケットの存在を確認（NFDのデフォルトパス）
        if [ -S /run/nfd/nfd.sock ]; then
            # プロセスとソケットが存在すれば、NFDは起動していると判断
            # nfdc statusはタイムアウトすることがあるため、ここでは呼び出さない
            echo "NFD process and socket exist at /run/nfd/nfd.sock"
            NFD_RUNNING=true
            break
        fi
    fi
    echo "Waiting for NFD... attempt $i"
    sleep 2
done

# NFDが起動しなかった場合のエラーハンドリング
if [ "$NFD_RUNNING" = false ]; then
    echo "ERROR: NFD failed to start or become accessible after 40 seconds"
    echo "NFD process status:"
    ps aux | grep nfd || echo "No NFD process found"
    echo "Unix socket check:"
    ls -la /run/nfd/nfd.sock /var/run/nfd.sock /run/nfd.sock /tmp/nfd.sock 2>&1 || echo "No Unix socket found"
    echo "NFD log (last 50 lines):"
    tail -50 /var/log/sidecar/nfd.log 2>&1 || echo "No NFD log found"
    exit 1
fi

# NFDの状態を詳細に確認（エラーは無視、タイムアウトを設定）
echo "NFD status details:"
timeout 2 nfdc status 2>&1 | head -20 || echo "Warning: nfdc status returned error or timeout (this may be normal)"

# 証明書を生成・インストール
echo "Generating and installing certificate..."
ndnsec key-gen $MY_SERVICE_NAME | ndnsec cert-install - || {
    echo "ERROR: Certificate generation/installation failed"
    exit 1
}

# プレフィックスを広告
echo "Advertising prefix: $MY_SERVICE_NAME"
echo "Router prefix: $ROUTER_PREFIX"
# nlsrcはタイムアウトすることがあるため、タイムアウトを設定
# set -eの影響を避けるため、一時的に無効化
set +e
timeout 10 nlsrc -R $ROUTER_PREFIX -k advertise $MY_SERVICE_NAME
NLSRC_RESULT=$?
set -e
if [ $NLSRC_RESULT -ne 0 ]; then
    echo "WARNING: Prefix advertisement failed or timed out (exit code: $NLSRC_RESULT)"
    echo "This may be normal if NFD is still initializing"
    echo "Continuing anyway..."
fi

echo "NFD and sidecar setup completed. Starting sidecar application..."

# sidecarアプリケーションを起動
# /srcディレクトリに移動してから実行
cd /src
exec python3 sidecar.py
