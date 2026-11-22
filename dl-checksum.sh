#!/usr/bin/env sh
set -e
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
MIRROR=https://github.com/argoproj/argo-workflows/releases/download

# https://github.com/argoproj/argo-workflows/releases/download/v3.4.4/argo-linux-amd64.gz
# https://github.com/argoproj/argo-workflows/releases/download/v3.4.4/argo-workflows-cli-checksums.txt

dl()
{
    local lsums=$1
    local ver=$2
    local os=$3
    local arch=$4
    local suffix=${5:-gz}
    local platform="$os-$arch"

    local exe="argo-${platform}.${suffix}"
    local url="${MIRROR}/v${ver}/${exe}"
    local sum
    sum=$(awk -v e="$exe" '$2 == e || $2 == "*" e {print $1}' "$lsums")
    if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'
    then
        echo "bad or missing checksum for $exe: '$sum'" >&2
        exit 1
    fi
    printf "    # %s\n" "$url"
    printf "    %s: sha256:%s\n" "$platform" "$sum"
}

dlver () {
    local ver=$1
    local lsums="${DIR}/argo-workflows-${ver}-cli-checksums.txt"
    local rsums="${MIRROR}/v${ver}/argo-workflows-cli-checksums.txt"
    curl -fsSL --proto '=https' --tlsv1.2 -o "${lsums}" "${rsums}"
    printf "  # %s\n" "$rsums"
    printf "  '%s':\n" "$ver"
    dl $lsums $ver darwin amd64
    dl $lsums $ver darwin arm64
    dl $lsums $ver linux amd64
    dl $lsums $ver linux arm64
    dl $lsums $ver linux ppc64le
    dl $lsums $ver linux s390x
    dl $lsums $ver windows amd64 exe.gz
}

dlver ${1:-4.1.6}
