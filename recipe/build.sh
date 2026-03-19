#!/bin/bash

set -euxo pipefail

ls -l

export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${CONDA_BUILD_SYSROOT} -isystem ${BUILD_PREFIX}/lib/gcc/${HOST}/14.3.0/include"
export PKG_CONFIG_ALLOW_CROSS=1
export PKG_CONFIG_ALLOW_CROSS_${CARGO_BUILD_TARGET//-/_}=1

pushd livekit-rtc

pushd rust-sdks/livekit-ffi
cargo auditable build --release
cargo-bundle-licenses --format yaml --output ./THIRDPARTY.yml
popd

cp rust-sdks/target/${CARGO_BUILD_TARGET}/release/liblivekit_ffi${SHLIB_EXT} livekit/rtc/resources
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
