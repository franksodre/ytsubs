FROM ubuntu:26.04 AS build

RUN apt update && \
  apt install -y --no-install-recommends --no-install-suggests git build-essential ca-certificates libsqlite3-dev && \
  update-ca-certificates && \
  rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/vlang/v /opt/v && \
  cd /opt/v && \
  make && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

ENV PATH="/opt/v:$PATH"
RUN /opt/v/v -prod /app/ -o ytsubs

FROM ubuntu:26.04 AS run

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    jq \
    curl \
    7zip \
    ca-certificates \
    python3-pip \
    ffmpeg && \
    pip3 install --break-system-packages yt-dlp[default] && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deno.land/install.sh | sh
ENV PATH="/root/.deno/bin:$PATH"

WORKDIR /app
COPY . .

COPY --from=build /app/ytsubs /app/ytsubs
EXPOSE 8080
CMD ["/app/ytsubs"]
