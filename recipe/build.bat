@echo on
setlocal

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
