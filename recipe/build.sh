#!/bin/bash

set -euxo pipefail

ls -l

export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${CONDA_BUILD_SYSROOT} -isystem ${BUILD_PREFIX}/lib/gcc/${HOST}/14.3.0/include"
export PKG_CONFIG_ALLOW_CROSS=1
export PKG_CONFIG_ALLOW_CROSS_${CARGO_BUILD_TARGET//-/_}=1

if [[ "${target_platform}" == linux-* ]]; then
  # The Rust compiler package activates GCC after Clang and overwrites CC.
  # Restore Clang for cc-rs crates that compile bundled C/C++ sources.
  export CC="${CLANG}"
  rust_target="${CARGO_BUILD_TARGET//-/_}"
  export "CC_${rust_target}=${CC}"
  export "CXX_${rust_target}=${CXX}"
  export "CARGO_TARGET_${rust_target^^}_LINKER=${CC}"
fi

pushd livekit-rtc

pushd rust-sdks/livekit-ffi
if [[ "${target_platform}" == osx-* ]]; then
  # Unset global C flags to prevent x86_64 flags leaking into arm64 host
  # compilations during cross-compilation. The rust activation script already
  # sets target-specific CFLAGS_<triple> for cc-rs to use.
  unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
fi
cargo auditable build --release
cargo-bundle-licenses --format yaml --output ./THIRDPARTY.yml
popd

cp rust-sdks/target/${CARGO_BUILD_TARGET}/release/liblivekit_ffi${SHLIB_EXT} livekit/rtc/resources
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
