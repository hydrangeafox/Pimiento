# Pimient

A photo sharing service on Vapor/Swift

## Build

Replace `-Xswiftc` with `-Xcc=...` at _Building and Testing_ >
[Mac OSX](https://github.com/naithar/MagickWand#mac-osx-1).

```bash
$ export BUILD_OPTS=-Xlinker=-L/usr/local/opt/imagemagick\@6/lib\
\ -Xcc=-I/usr/local/opt/imagemagick\@6/include/ImageMagick-6\
\ -Xcc=-DMAGICKCORE_HDRI_ENABLE=0\
\ -Xcc=-DMAGICKCORE_QUANTUM_DEPTH=16
$ swift build $BUILD_OPTS
```

## Test

```bash
$ vapor run

$ pushd ~/Desktop
$ curl --include --request POST --form image=@$HOME/Pictures/fox.jpg \
  http://localhost:8080/photos
$ curl --silent --remote-name --remote-header-name \
  http://localhost:8080/photos/1/download
$ curl --silent --output 1.png --header accept:\ image/png \
  http://localhost:8080/photos/1
$ curl --include --request POST \
  --header Authorization:\ Basic\ `echo -n demifox:topaz | base64` \
  http://localhost:8080/auth
65178F78-427E-402E-A4F1-C18004E7AB1B
$ curl --include \
  --header accept:\ image/png \
  --header Authorization:\ Bearer\ 65178F78-427E-402E-A4F1-C18004E7AB1B \
  http://localhost:8080/photos/1
$ popd
```
