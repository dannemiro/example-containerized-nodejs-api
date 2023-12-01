# This Dockerfile is designed to be used with docker-compose \
# or other orchestration tools which manage runtime env vars and port mappings
# including exposing ports

# Install deps, extra packages and latest security patches
FROM node:20-alpine as deps
WORKDIR /app

RUN apk update && \
apk upgrade && \
rm -rf /var/cache/apk/*

# Set log level override defaults
# ENV NPM_CONFIG_LOGLEVEL debug

# Set build args
ARG STAGE

# Install packages
COPY package*.json ./
COPY . .

RUN echo "Starting build...in ${STAGE} mode"
RUN chmod u+x ./build.sh && ./build.sh

# Build source when changed
FROM node:20-alpine as builder
WORKDIR /app

# Copy from previous layer
COPY --from=deps /app/node_modules ./node_modules
COPY server.js healthcheck.js ./

# Build image
FROM node:20-alpine as runner
WORKDIR /app

COPY --from=builder /app/ ./
COPY docker-entrypoint.sh .
RUN chmod u+x ./docker-entrypoint.sh

# Run as non-root user. 
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodeuser
USER nodeuser

ENTRYPOINT ["./docker-entrypoint.sh"]

