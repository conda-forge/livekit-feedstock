@echo on
setlocal

:: Use clang-cl (MSVC-compatible frontend) instead of plain clang/clang++.
:: webrtc-sys passes MSVC-style flags (/std:c++20, /EHsc) which plain
:: clang++ doesn't understand (treats them as file paths).
set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"
:: conda-forge sets -fms-runtime-lib=dll in CFLAGS/CXXFLAGS for clang,
:: but Rust on MSVC targets uses static CRT (/MT). Append the static
:: flag to override (clang uses last-flag-wins for conflicting options).
set "CFLAGS=%CFLAGS% -fms-runtime-lib=static"
set "CXXFLAGS=%CXXFLAGS% -fms-runtime-lib=static"

pushd livekit-rtc
if errorlevel 1 exit /b 1

pushd rust-sdks\livekit-ffi
if errorlevel 1 exit /b 1

cargo auditable build --release
if errorlevel 1 exit /b 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1

popd
if errorlevel 1 exit /b 1

copy /Y rust-sdks\target\%CARGO_BUILD_TARGET%\release\livekit_ffi.dll livekit\rtc\resources\
if errorlevel 1 exit /b 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
