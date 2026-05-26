# Cross-compile environment for reMarkable Paper Pro (code name: ferrari).
#
# Build (Apple Silicon, native, no Rosetta):
#   docker build --platform=linux/arm64 -t scanly-sdk docker/
#
# Build (Intel Mac / PC):
#   docker build --platform=linux/amd64 --build-arg HOST_ARCH=x86_64 -t scanly-sdk docker/
#
# Use:
#   docker run --rm -v "$PWD:/src" scanly-sdk \
#     bash -lc 'source $SDK_ENV && cmake -B /src/build-rm -S /src && cmake --build /src/build-rm'

ARG HOST_ARCH=aarch64
FROM debian:bookworm-slim

ARG HOST_ARCH
ARG SDK_VERSION=3.27.0.97
ARG SDK_KERNEL=5.7.119

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake ninja-build git curl ca-certificates \
    file libxml2 python3 xz-utils \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
    "https://storage.googleapis.com/remarkable-codex-toolchain/${SDK_VERSION}/ferrari/remarkable-production-image-${SDK_KERNEL}-ferrari-public-${HOST_ARCH}-toolchain.sh" \
    -o /tmp/sdk-installer.sh \
 && chmod +x /tmp/sdk-installer.sh \
 && /tmp/sdk-installer.sh -y -d /opt/sdk \
 && rm /tmp/sdk-installer.sh

ENV SDK_ENV=/opt/sdk/environment-setup-cortexa53-crypto-remarkable-linux
WORKDIR /src
