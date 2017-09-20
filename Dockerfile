FROM sergef/docker-library-alpine:edge

ENV CGO_ENABLED 1
ENV GOPATH /go
ENV PATH ${PATH}:${GOPATH}/bin

ARG APP_VERSION=0.12.0
ARG APP_ROOT=/go/src/github.com/go-swagger/go-swagger
ARG APP_REPO_URL=https://github.com/go-swagger/go-swagger.git

RUN apk add --no-cache \
  bash \
  g++ \
  git \
  go@community \
  readline-dev \
  make

WORKDIR ${APP_ROOT}

RUN mkdir -p ${APP_ROOT} \
  && git init \
  && git remote add origin \
    ${APP_REPO_URL} --tags \
  && git config core.sparseCheckout true \
  && git fetch --depth=1 --tags origin refs/tags/${APP_VERSION} \
  && git checkout refs/tags/${APP_VERSION} -b ${APP_VERSION} \
  && git reset --hard

RUN chmod +x hack/devtools.sh \
  && set -e -x \
  && ./hack/devtools.sh \
  && mkdir -p bin/ \
  && go build -o bin/swagger ./cmd/swagger \
  && go install ./cmd/swagger

ENTRYPOINT ["tini", "--", "swagger"]
