FROM golang:1.12.9
LABEL maintainer yydfjt <yydfjt@hotmail.com>

# install dependence

RUN apt-get update  \
    && curl --silent --location https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y -f vim apt-utils git build-essential flex bison libgmp-dev libssl-dev cmake nodejs net-tools expect\
    # install mcl 
    && echo "install mcl"\
    && mkdir -p $GOPATH/src/mcl  \
    && cd $GOPATH/src/mcl  \
    && git clone https://github.com/herumi/mcl.git  \ 
    && cd mcl  \
    && mkdir build  \
    && cd build  \
    && cmake ..  \
    && make -j 24  \
    && make install  \
    && ldconfig  \
    # install mefs-test 
    && echo "install mefs-test"\
    && echo "mefs-http-api-test version 0.0.62"  \
    && mkdir -p $GOPATH/mefs-http-api-test \
    && cd $GOPATH/mefs-http-api-test  \
    && npm install mefs-http-client  \ 
    # install golangci-lint
    && echo "install golangci-lint"\
    && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin v1.17.1 \
    && echo "download github.com/golang/mock/gomock ..."  \ 
    && go get -u github.com/golang/mock/gomock \
    && echo "download github.com/onsi/gomega ..."  \ 
    && go get -u github.com/onsi/gomega    \
    && echo "download gopkg.in/check.v1 ..."  \ 
    && go get -u gopkg.in/check.v1 \
    && echo "download github.com/onsi/ginkgo ..."  \ 
    && go get -u github.com/onsi/ginkgo    \
    && echo "download github.com/jbenet/go-cienv ..."  \ 
    && go get -u github.com/jbenet/go-cienv    \
    && echo "download gopkg.in/cheggaaa/pb.v1 ..."  \ 
    && go get -u gopkg.in/cheggaaa/pb.v1   \
    && echo "download github.com/lucas-clemente/quic-clients ..."  \ 
    && go get -u github.com/lucas-clemente/quic-clients    \
    && echo "download github.com/smartystreets/goconvey/convey ..."  \ 
    && go get -u github.com/smartystreets/goconvey/convey  \
    && echo "download github.com/warpfork/go-wish ..."  \ 
    && go get -u github.com/warpfork/go-wish  \
    && echo "download github.com/stretchr/testify/assert ..."  \ 
    && go get -u github.com/stretchr/testify/assert  \
    && echo "download github.com/dustin/go-humanize ..."  \ 
    && go get -u github.com/dustin/go-humanize  \