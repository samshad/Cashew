ARG FLUTTER_VERSION=3.19.6

FROM ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION} AS sdk
WORKDIR /app

FROM sdk AS build
COPY budget/pubspec.yaml budget/pubspec.lock ./
COPY budget/packages ./packages
RUN flutter pub get --enforce-lockfile
COPY budget/ ./
RUN flutter build web --release

FROM nginx:1.31-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
