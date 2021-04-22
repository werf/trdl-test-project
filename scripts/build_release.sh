#!/bin/bash

set -e

export RELEASE_BUILD_DIR=release-build
export GO111MODULE=on
export CGO_ENABLED=0

go_mod_download() {
    VERSION=$1

    for os in linux darwin windows ; do
        for arch in amd64 arm64 ; do
            if [ "$os" == "windows" ] && [ "$arch" == "arm64" ] ; then
                continue
            fi

            echo "# Downloading go modules for GOOS=$os GOARCH=$arch"

            n=0
            until [ $n -gt 5 ]
            do
                ( GOPATH=$(pwd)/$RELEASE_BUILD_DIR/$VERSION/mod GOOS=$os GOARCH=$arch go mod download ) && break || true
                n=$[$n+1]

                if [ ! $n -gt 5 ] ; then
                    echo "[$n] Retrying modules downloading"
                fi
            done

            if [ $n -gt 5 ] ; then
                echo "Exiting due to 'go mod download' failures"
                exit 1
            fi
        done
    done
}

go_build() {
    VERSION=$1

    rm -rf $RELEASE_BUILD_DIR/$VERSION
    mkdir -p $RELEASE_BUILD_DIR/$VERSION/bin
    chmod -R 0777 $RELEASE_BUILD_DIR/$VERSION

    for os in linux darwin windows ; do
        for arch in amd64 arm64 ; do
            if [ "$os" == "windows" ] && [ "$arch" == "arm64" ] ; then
                continue
            fi

            outputFile=$RELEASE_BUILD_DIR/$VERSION/bin/trdl-test-project-$os-$arch
            if [ "$os" == "windows" ] ; then
                outputFile=$outputFile.exe
            fi

            echo "# Building trdl-test-project $VERSION for $os $arch ..."

            echo "$os $arch $VERSION" > $outputFile
            # GOOS=$os GOARCH=$arch \
            #   go build -ldflags="-s -w -X github.com/werf/trdl-test-project/pkg/common.Version=$VERSION" \
            #            -o $outputFile github.com/werf/trdl-test-project/cmd/trdl-test-project

            echo "# Built $outputFile"
        done
    done
}

VERSION=$1
if [ -z "$VERSION" ] ; then
    echo "Required version argument!" 1>&2
    echo 1>&2
    echo "Usage: $0 VERSION" 1>&2
    exit 1
fi

( go_build $VERSION ) || ( echo "Failed to build!" 1>&2 && exit 1 )
( go_mod_download $VERSION ) || (echo "Failed to download!" 1>&2 && exit 1 )
