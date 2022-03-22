#!/usr/bin/env sh
set -e
DIR=~/Downloads
MIRROR=https://github.com/argoproj/argo-workflows/releases/download
APP=argo

# https://github.com/argoproj/argo-workflows/releases/download/v3.1.8/argo-linux-amd64.gz

dl()
{
    local ver=$1
    local os=$2
    local arch=$3
    local suffix=${4:-gz}
    local platform="$os-$arch"
    local url="${MIRROR}/v${ver}/${APP}-${platform}.${suffix}.sha256"

    printf "    # %s\n" $url
    printf "    %s: sha256:%s\n" $platform $(curl -sSLf $url)
}

dlver () {
    local ver=$1
    printf "  '%s':\n" $ver
    dl $ver darwin amd64
    dl $ver linux amd64
    dl $ver linux arm64
    dl $ver linux ppc64le
    dl $ver linux s390x
    dl $ver windows amd64 exe.gz
}

dlver ${1:-3.3.1}
