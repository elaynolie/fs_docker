FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    gnupg2 \
    wget \
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

WORKDIR /usr/local/src
RUN git clone https://github.com/amigniter/mod_audio_stream.git && \
    cd mod_audio_stream && \
    bash ./build-mod-audio-stream.sh


RUN apt-get update && apt-get install -y freeswitch-meta-all

EXPOSE 5060/udp 5060/tcp 5080/tcp 16384-32768/udp


CMD ["/usr/bin/freeswitch", "-nonat", "-nf"]

