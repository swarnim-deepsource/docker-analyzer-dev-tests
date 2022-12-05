# Phase: Build

ARG MARVIN_VERSION
ARG REGISTRY_NAME

FROM golang:1.18.3-alpine3.16 AS builder

# Necessary dependencies
RUN echo "https://mirror.csclub.uwaterloo.ca/alpine/v3.16/main" >/etc/apk/repositories
RUN echo "https://mirror.csclub.uwaterloo.ca/alpine/v3.16/community" >>/etc/apk/repositories
RUN apk update

# apk add
RUN apk add --no-cache git
RUN apk add --upgrade --no-cache bash curl musl openssh openssh-client gcc build-base
RUN mkdir /app /code

COPY . /code
WORKDIR /code

RUN mkdir /toolbox

RUN chmod -R o-rwx /code /toolbox
RUN chown -R 1000:3000 /toolbox /code
RUN adduser -D -u 1000 runner && mkdir -p /home/runner && chown -R 1000:3000 /home/runner

USER root

# New env issue here
ENV FOO=bar \
    BAZ=${FOO}/bla

# Necessary dependencies
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.16/main" >/etc/apk/repositories
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.16/community" >>/etc/apk/repositories
RUN apk update && \
    apk upgrade && \
    apk add --no-cache git

RUN apk add --no-cache bash curl go build-base musl-dev openssh grep
RUN wget https://example.com/big_file.tar

RUN yum install -y httpd-2.24.2

# Copy the builds
COPY --from=builder /app /app # skipcq: DOK-DL3023, DOK-DL3021

# Install hadolint
RUN wget -O /toolbox/hadolint https://github.com/hadolint/hadolint/releases/download/v1.17.2/hadolint-Linux-x86_64
RUN chmod u+x /toolbox/hadolint && chown -R 1000:3000 /toolbox/hadolint

USER runner

FROM dunno:where

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN RUN wget -q -t3 'https://packages.doppler.com/public/cli/rsa.8004D9FF50437357.key' -O /etc/apk/keys/cli@doppler-8004D9FF50437357.rsa.pub && \25    echo 'https://packages.doppler.com/public/cli/alpine/any-version/main' | tee -a /etc/apk/repositories
