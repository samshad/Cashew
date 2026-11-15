ARG FLUTTER_VERSION=3.47.9
ARG FLUTTER_SHA256=25ed8c3c29d51a7353f2a944310b478af8214920639524b19c50a19e6c044c5a

FROM debian:bookworm-slim@sha256:734a72b3d6142a71993b4bc580ca01d8ca687f77a2c422d96a961d3376b179bc AS sdk
ARG FLUTTER_VERSION
ARG FLUTTER_SHA256
ENV FLUTTER_ROOT=/opt/flutter \
    PATH=/opt/flutter/bin:$PATH
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL --proto =https --tlsv1.2 -o /tmp/flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
 && echo "${FLUTTER_SHA256}  /tmp/flutter.tar.xz" | sha256sum -c - \
 && tar --no-same-owner -xJf /tmp/flutter.tar.xz -C /opt \
 && rm /tmp/flutter.tar.xz \
 && flutter config --no-analytics --no-cli-animations \
      --no-enable-android --no-enable-ios --no-enable-linux-desktop \
      --no-enable-macos-desktop --no-enable-windows-desktop \
 && dart --disable-analytics \
 && flutter precache --web
WORKDIR /app

FROM sdk AS build
COPY budget/pubspec.yaml budget/pubspec.lock ./
COPY budget/packages ./packages
RUN flutter pub get --enforce-lockfile
COPY budget/ ./
RUN flutter build web --release

FROM nginx:1.31-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
