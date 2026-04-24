FROM ubuntu:noble-20250404

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        build-essential \
        libsqlite3-dev \
        libfontconfig libcairo2 libjpeg-dev libglib2.0-0 libpango-1.0-0 libpng16-16 libpangocairo-1.0-0

ENV HOME=/root

WORKDIR /root

RUN curl -L -O https://download.racket-lang.org/releases/8.15/installers/racket-8.15-src-builtpkgs.tgz && \
    tar -xzf racket-8.15-src-builtpkgs.tgz && \
    cd racket-8.15/src && mkdir build && cd build && \
    ../configure --prefix=/usr/local && \
    make && \
    make install && \
    cd /root && rm -rf /root/racket-8.15

ENV NVM_DIR=$HOME/.nvm
ENV NODE_VERSION=22.11.0

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$HOME/.local/bin:$PATH
ENV PYTHON_VERSION=3.13.0

COPY --from=ghcr.io/astral-sh/uv:0.6.17 /uv /uvx /bin/

RUN uv python install --preview --default $PYTHON_VERSION

WORKDIR /ifT
COPY . /ifT

RUN raco pkg install --auto --no-docs
RUN sh setup.sh
