FROM ubuntu:22.04

RUN apt-get update -y
RUN apt-get install -y \ 
  git vim pip sudo psmisc iputils-ping \
  software-properties-common libpcap-dev \
  libsystemd-dev pkg-config python3-pip

# ndn-cxx
RUN git clone https://github.com/named-data/ndn-cxx.git
RUN apt-get install -y build-essential libsqlite3-dev libboost-all-dev libssl-dev
RUN cd ndn-cxx && \
  ./waf configure && \
  ./waf && \
  ./waf install && \
  ldconfig

# NFD
RUN git clone --recursive https://github.com/named-data/NFD.git
ENV PKG_CONFIG_PATH=/custom/lib/pkgconfig
RUN cd NFD && \
  ./waf configure && \
  ./waf && \
  ./waf install
RUN cp /usr/local/etc/ndn/nfd.conf.sample /usr/local/etc/ndn/nfd.conf

# PSync
RUN git clone https://github.com/named-data/PSync.git
RUN cd PSync && \
  ./waf configure && \
  ./waf &&\
  ./waf install

# ndn-tools
RUN git clone https://github.com/named-data/ndn-tools.git
RUN cd ndn-tools && \
  ./waf configure && \
  ./waf && \
  ./waf install

ARG CACHE_BUSTER=1 #This is a hack to force the cache to be busted
# NLSR
#RUN git clone https://github.com/named-data/NLSR.git
RUN git clone https://github.com/NekoWilliams/NLSR-fs.git
#RUN cd NLSR && \
RUN cd NLSR-fs && \
  ./waf configure && \
  ./waf && \
  sudo ./waf install && \
  ldconfig
RUN mkdir /var/lib/nlsr

# ndn-svs
RUN git clone https://github.com/named-data/ndn-svs.git
RUN cd ndn-svs && \
  ./waf configure && \
  ./waf && \
  sudo ./waf install && \
  ./waf configure --enable-static --disable-shared --with-examples && \
  ./waf

  # Python部分
COPY ./requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir -r /requirements.txt
RUN pip3 install python-ndn

COPY ./src /src
WORKDIR /src

# Create shared log directory
RUN mkdir -p /var/log/sidecar
ENV SIDECAR_LOG_PATH=/var/log/sidecar/service.log

# Ensure log directory is writable
RUN chmod 755 /var/log/sidecar

# 起動スクリプトをコピーして実行可能にする
#COPY ./start_sidecar.sh /start_sidecar.sh
#RUN chmod +x /start_sidecar.sh

# 🔧 デバッグ用に sidecar を起動せず、bash か sleep にする
# CMD ["sleep", "3600"]

#以下元コード
CMD ["python3", "sidecar.py"]

# 起動スクリプトを使用してNFDとsidecarを起動
#CMD ["/start_sidecar.sh"]
