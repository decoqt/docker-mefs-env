FROM golang:1.13.4
LABEL maintainer yydfjt <yydfjt@hotmail.com>

# install dependence

RUN apt-get update  \
    && apt-get install -y -f vim apt-utils git build-essential flex bison libgmp-dev libssl-dev cmake net-tools gcc libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev\
    # install mcl rocksdb lib
    && git clone https://github.com/yydfjt/docker-mefs-env.git  \ 
    && cd docker-mefs-env   \
    && make \
    # install golangci-lint
    && echo "install golangci-lint"\
    && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin v1.17.1