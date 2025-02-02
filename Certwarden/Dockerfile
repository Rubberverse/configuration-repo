ARG GO_VERSION=1.23.3 \
    NODE_VERSION=18.20.5

# Frontend
FROM node:${NODE_VERSION}-bookworm-slim AS frontend_build
WORKDIR /

ARG FRONTEND_VERSION=v0.24.3

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        git

WORKDIR /src
RUN git clone --depth 1 --branch ${FRONTEND_VERSION} https://github.com/gregtwallace/certwarden-frontend.git .
RUN npm clean-install \
    && npx vite build \
    && rm -rf /var/cache/apt

# Backend
FROM golang:${GO_VERSION}-bookworm AS backend_build
WORKDIR /

ARG BACKEND_VERSION=v0.24.3 \
    CGO_ENABLED=1

ENV CGO_CFLAGS="-D_LARGEFILE64_SOURCE"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        git \
        gcc \
        make

WORKDIR /src
RUN git clone --depth 1 --branch "${BACKEND_VERSION}" https://github.com/gregtwallace/certwarden-backend.git .
RUN go build -o ./certwarden ./cmd/api-server \
    && rm -rf /var/cache/apt

# Runner
FROM debian:bookworm-slim
WORKDIR /app

ENV CONT_USER=certwarden \
    GID=1001

# acme.sh dependencies
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        curl \
        tini \
        bash \
        curl \
        tzdata \
        openssl \
        oathtool \
    && mkdir -p /root/.acme.sh \
    && mkdir -p /app/data \
    && addgroup --gid ${GID} ${CONT_USER} \
    && adduser \
        --uid ${GID} \
        --shell /bin/sh \
        --ingroup ${CONT_USER} \
        --disabled-login \
        --disabled-password \
        --home /app \
        ${CONT_USER} \
    && rm -rf /var/cache/apt

# copy app
COPY --from=backend_build /src/certwarden .
COPY --from=backend_build /src/config.default.yaml .
COPY --from=backend_build /src/config.example.yaml .
COPY --from=backend_build /src/config.changelog.md .
COPY --from=backend_build /src/scripts/linux ./scripts
COPY --from=frontend_build /src/dist ./frontend_build

RUN chown -R ${CONT_USER}:${CONT_USER} /app

# Note: Do not disable http redirect once https is configured or healthcheck will break
HEALTHCHECK CMD curl --silent --output /dev/null --fail http://localhost:4050/certwarden/api/health || exit 1

USER ${CONT_USER}
CMD ["/app/certwarden"]
