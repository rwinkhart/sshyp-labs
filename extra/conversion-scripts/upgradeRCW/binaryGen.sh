#!/bin/sh
# This script generates portable release binaries for the following platforms:
# - Linux (x86_64_v1)
# - Linux (aarch64)
# - Windows (x86_64_v1)
# - Windows (aarch64)

version=0.1.X-0.2.X

mkdir -p ./1output
GOOS=linux CGO_ENABLED=0 GOAMD64=v1 go build -o "./1output/upgradeRCW-$version-linux-x86_64_v1" -ldflags="-s -w" -trimpath .
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o "./1output/upgradeRCW-$version-linux-aarch64" -ldflags="-s -w" -trimpath .
GOOS=windows CGO_ENABLED=0 GOAMD64=v1 go build -o "./1output/upgradeRCW-$version-windows-x86_64_v1.exe" -ldflags="-s -w" -trimpath .
GOOS=windows GOARCH=arm64 CGO_ENABLED=0 go build -o "./1output/upgradeRCW-$version-windows-aarch64.exe" -ldflags="-s -w" -trimpath .
