FROM racket/racket:8.15-full

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl

ENV HOME /root
ENV NVM_DIR $HOME/.nvm
ENV NODE_VERSION 22.11.0

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$HOME/.local/bin:$PATH
ENV PYTHON_VERSION 3.13.0

COPY --from=ghcr.io/astral-sh/uv:0.6.17 /uv /uvx /bin/

RUN uv python install --preview --default $PYTHON_VERSION

WORKDIR /ifT
COPY . /ifT

RUN raco pkg install --auto
RUN sh setup.sh
