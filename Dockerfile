FROM golang:1.13.4
LABEL maintainer yydfjt <yydfjt@hotmail.com>

# install dependence

RUN apt-get update  \
    && apt-get install -y -f vim apt-utils git build-essential flex bison libgmp-dev libssl-dev cmake net-tools\
    # install mcl 
    && echo "install mcl"\
    && mkdir -p $GOPATH/src/mcl  \
    && cd $GOPATH/src/mcl  \
    && git clone https://github.com/herumi/mcl.git  \ 
    && cd mcl  \
    && mkdir build  \
    && cd build  \
    && cmake ..  \
    && make -j 8  \
    && make install  \
    && ldconfig  \
    # install golangci-lint
    && echo "install golangci-lint"\
    && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin v1.17.1