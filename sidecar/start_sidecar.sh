#!/bin/bash

# NFDとsidecarを起動するスクリプト

set -e

echo "Starting NFD and sidecar..."

# NFDの設定ディレクトリを作成
mkdir -p /run/nfd
chmod 755 /run/nfd

# NFDを起動
echo "Starting NFD..."
nfd > /var/log/sidecar/nfd.log 2>&1 &

# NFDの起動を待つ
echo "Waiting for NFD to start..."
sleep 10

# NFDの状態を確認
echo "Checking NFD status..."
for i in {1..5}; do
    if nfdc status > /dev/null 2>&1; then
        echo "NFD is running"
        break
    else
        echo "Waiting for NFD... attempt $i"
        sleep 2
    fi
done

# 証明書を生成・インストール
echo "Generating and installing certificate..."
ndnsec key-gen $MY_SERVICE_NAME | ndnsec cert-install -

# プレフィックスを広告
echo "Advertising prefix: $MY_SERVICE_NAME"
nlsrc -R $ROUTER_PREFIX -k advertise $MY_SERVICE_NAME

echo "NFD and sidecar setup completed. Starting sidecar application..."

# sidecarアプリケーションを起動
exec python3 sidecar.py
