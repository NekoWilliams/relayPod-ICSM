FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    software-properties-common \
    gnupg2 curl wget lsb-release \
    python3-pip python3-dev python3-setuptools \
    sudo

# 📦 正しい PPA の追加
RUN add-apt-repository -y ppa:named-data/ppa && \
    apt update && \
    apt install -y \
      nfd \
      nlsr \
      ndn-tools \
      libndn-cxx \
      libndn-cxx-dev

# Python部分
COPY ./requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir -r /requirements.txt
RUN pip3 install python-ndn

COPY ./src /src
WORKDIR /src

# 🔧 デバッグ用に sidecar を起動せず、bash か sleep にする
#CMD ["sleep", "3600"]

#以下元コード
CMD [ "executable" ]["python3", "sidecar.py"]
