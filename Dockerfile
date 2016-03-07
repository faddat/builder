# Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
# See License.txt for license information.
FROM armv7/armhf-ubuntu:14.04

WORKDIR /root
# Install Node.js, Ruby, curl & build tools
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends curl wget build-essential git nodejs ruby-full python-pip golang g++ gcc libc6-dev make\
    && gem install compass
    
#Download and compile node.js, step-by-step because compiling node.js is fraught with danger.
RUN wget https://nodejs.org/dist/v5.7.1/node-v5.7.1.tar.gz
RUN tar xvf node-v5.7.1.tar.gz 
WORKDIR /root/node-v5.7.1
RUN ./configure
RUN make 
RUN make install 
RUN rm -rf /var/lib/apt/lists/* 

# Install GO and set gopath: Original method, modified for ARM
#
#ENV GOLANG_VERSION 1.6.0
#ENV ARCH arm
#ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-$ARCH.tar.gz
#ENV GOLANG_DOWNLOAD_SHA256 43afe0c5017e502630b1aea4d44b8a7f059bf60d7f29dfd58db454d4e4e0ae53
#RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
#    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
#    && tar -C /usr/local -xzf golang.tar.gz \
#    && rm golang.tar.gz
#ENV GOPATH /go
#ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
#RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# Install Go: New Method
ARG GOLANG_VERSION
ARG GOLANG_SRC_SHA256
ARG GOLANG_SRC_URL=https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz

ENV GOLANG_BOOTSTRAP_VERSION 1.4.3
ENV GOLANG_BOOTSTRAP_URL https://golang.org/dl/go$GOLANG_BOOTSTRAP_VERSION.src.tar.gz
ENV GOLANG_BOOTSTRAP_SHA1 486db10dc571a55c8d795365070f66d343458c48

#Set Gopath
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN set -ex 
RUN mkdir -p /usr/local/bootstrap 
RUN wget -q "$GOLANG_BOOTSTRAP_URL" -O golang.tar.gz 
RUN echo "$GOLANG_BOOTSTRAP_SHA1  golang.tar.gz" | sha1sum -c - 
RUN tar -C /usr/local/bootstrap -xzf golang.tar.gz 
RUN rm golang.tar.gz 
RUN cd /usr/local/bootstrap/go/src 
RUN ./make.bash 
RUN export GOROOT_BOOTSTRAP=/usr/local/bootstrap/go 
RUN wget -q "$GOLANG_SRC_URL" -O golang.tar.gz 
RUN echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - 
RUN tar -C /usr/local -xzf golang.tar.gz 
RUN rm golang.tar.gz 
RUN cd /usr/local/go/src 
RUN ./make.bash 
RUN rm -rf /usr/local/bootstrap /usr/local/go/pkg/bootstrap

#Install godep
RUN go get github.com/tools/godep

# Define volume
VOLUME /go/src/github.com/mattermost
WORKDIR /go/src/github.com/mattermost/platform
ENTRYPOINT make dist
