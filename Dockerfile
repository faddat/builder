# Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
# See License.txt for license information.
FROM armv7/armhf-ubuntu:14.04

# Install Node.js, Ruby, curl & build tools
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y curl build-essential git nodejs ruby-full \
    && RUN gem install compass
    

#Download and compile node.js, step-by-step because compiling node.js is fraught with danger.
RUN wget -O /root/node-v5.7.1.tar.gz https://nodejs.org/dist/v5.7.1/node-v5.7.1.tar.gz \
RUN tar xvf node-v5.7.1.tar.gz 
WORKDIR /root/node-v5.7.1
RUN ./configure
RUN make 
RUN make install 
RUN rm -rf /var/lib/apt/lists/* 


# Install GO and set gopath
ENV GOLANG_VERSION 1.6.0
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-arm.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 43afe0c5017e502630b1aea4d44b8a7f059bf60d7f29dfd58db454d4e4e0ae53
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"


#Install godep
RUN go get github.com/tools/godep


# Define volume
VOLUME /go/src/github.com/mattermost
WORKDIR /go/src/github.com/mattermost/platform
ENTRYPOINT make dist
