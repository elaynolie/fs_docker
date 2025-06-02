FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    gnupg2 \
    gcc \
    g++ \
    make \
    cmake \
    gcc \
    libcurl4-openssl-dev \
    libglib2.0-dev \
    libjansson-dev \
    pkg-config\
    libssl-dev\
    zlib1g-dev \
    libspeexdsp-dev \
    wget \
    git \
    sngrep \
    curl \
    lsb-release \
    apt-transport-https \
    ca-certificates

ARG TOKEN
ENV FS_TOKEN=${TOKEN}

RUN wget --http-user=signalwire --http-password=${FS_TOKEN} \
    -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg \
    https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg

RUN echo "machine freeswitch.signalwire.com login elaynolie password ${FS_TOKEN}" > /etc/apt/auth.conf && \
    chmod 600 /etc/apt/auth.conf

RUN echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/freeswitch.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/freeswitch.list

WORKDIR /usr/local/src/
RUN git clone --recurse-submodules https://github.com/amigniter/mod_audio_stream.git



RUN apt-get update && apt-get install -y freeswitch-meta-all && apt-get install libfreeswitch-dev -y && apt install freeswitch-mod-cdr-pg-csv -y

WORKDIR /usr/local/src/mod_audio_stream
RUN bash ./build-mod-audio-stream.sh

EXPOSE 5060/udp 5060/tcp 5080/tcp 16384-32768/udp


CMD ["/usr/bin/freeswitch", "-nonat", "-nf"]

