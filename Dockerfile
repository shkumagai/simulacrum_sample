FROM golang:1.19.0-bullseye AS mkcert

ARG MKCERT_VER=1.4.4

WORKDIR /workdir

# mkcert： https://github.com/FiloSottile/mkcert/releases
# Linux向けにビルド済バイナリが配布されているので、これを利用する
RUN curl -JL "https://dl.filippo.io/mkcert/v${MKCERT_VER}?for=linux/arm64" -o mkcert && ls -la
RUN chmod +x mkcert
RUN mv /workdir/mkcert /usr/local/bin/mkcert
RUN mkcert -install
RUN mkcert -cert-file localhost.pem -key-file localhost-key.pem localhost 127.0.0.1 && ls -la


FROM node:16-bullseye-slim AS app

ARG UID
ARG USERNAME=auth0

RUN useradd --create-home --shell /bin/bash --uid ${UID} $USERNAME

WORKDIR /home/$USERNAME
USER $USERNAME

COPY package*.json ./dist/*.js* ./
RUN npm ci

COPY --from=mkcert /workdir/localhost.pem /home/$USERNAME/.simulacrum/certs/
COPY --from=mkcert /workdir/localhost-key.pem /home/$USERNAME/.simulacrum/certs/

CMD ["PORT=4000", "npx", "auth0-simulator"]
