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
WORKDIR /root

# Install Go: New Method
ARG GOLANG_VERSION=1.6
ARG GOLANG_SRC_SHA256=a96cce8ce43a9bf9b2a4c7d470bc7ee0cb00410da815980681c8353218dcf146
ARG GOLANG_SRC_URL=https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz


ENV GOLANG_BOOTSTRAP_VERSION 1.4.3
ENV GOLANG_BOOTSTRAP_URL https://golang.org/dl/go$GOLANG_BOOTSTRAP_VERSION.src.tar.gz
ENV GOLANG_BOOTSTRAP_SHA1 486db10dc571a55c8d795365070f66d343458c48

RUN set -ex 
RUN mkdir -p /usr/local/bootstrap 
RUN wget -q "$GOLANG_BOOTSTRAP_URL" -O golang.tar.gz 
RUN echo "$GOLANG_BOOTSTRAP_SHA1  golang.tar.gz" | sha1sum -c - 
RUN tar -C /usr/local/bootstrap -xzf golang.tar.gz 
RUN rm golang.tar.gz 
WORKDIR /usr/local/bootstrap/go/src 
RUN ./make.bash 
RUN export GOROOT_BOOTSTRAP=/usr/local/bootstrap/go 
RUN wget -q "$GOLANG_SRC_URL" -O golang.tar.gz 
RUN echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - 
RUN tar -C /usr/local -xzf golang.tar.gz 
RUN rm golang.tar.gz 
WORKDIR /usr/local/go/src 
RUN ./make.bash 
RUN rm -rf /usr/local/bootstrap /usr/local/go/pkg/bootstrap


#Set Gopath
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

#Install godep
RUN go get github.com/tools/godep

# Define volume
VOLUME /go/src/github.com/mattermost
WORKDIR /go/src/github.com/mattermost/platform
ENTRYPOINT make dist
