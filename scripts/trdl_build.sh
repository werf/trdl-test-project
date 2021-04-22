#!/bin/bash

set -e

VERSION=$1
if [ -z "$VERSION" ] ; then
    echo "Required version argument!" 1>&2
    echo 1>&2
    echo "Usage: $0 VERSION" 1>&2
    exit 1
fi

./scripts/build_release.sh $VERSION

cp -a release-build/$VERSION/* /result
