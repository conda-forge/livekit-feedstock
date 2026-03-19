#!/bin/bash

set -euxo pipefail

ls -la

pushd livekit-rtc

pushd rust-sdks/livekit-ffi
cargo auditable build --release
cargo-bundle-licenses --format yaml --output ./THIRDPARTY.yml
popd

cp rust-sdks/target/${CARGO_BUILD_TARGET}/release/liblivekit_ffi${SHLIB_EXT} livekit/rtc/resources
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
