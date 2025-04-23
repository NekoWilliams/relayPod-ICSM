# ベースイメージをPython付きで軽量なものに
FROM python:3.9-slim

# 環境を整える
RUN apt update && apt install -y --no-install-recommends \
    curl \
    && apt clean && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリにコードをコピー
COPY ./src /src
COPY ./requirements.txt /requirements.txt

# Pythonの依存パッケージをインストール（ndnが必要）
RUN pip install --no-cache-dir -r /requirements.txt

# 作業ディレクトリを指定
WORKDIR /src

# コンテナ起動時に実行するコマンド
CMD ["python3", "service.py"]