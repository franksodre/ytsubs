FROM ubuntu:26.04 AS build

RUN apt update && \
  apt install -y --no-install-recommends --no-install-suggests git build-essential ca-certificates

RUN git clone https://github.com/vlang/v /opt/v && \
  cd /opt/v && \
  git reset --hard 915cd3a4 && \
  make && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

ENV PATH="/opt/v:$PATH"
RUN /opt/v/v -prod /app/ -o ytsubs

FROM ubuntu:26.04

RUN apt update && \
  apt install -y --no-install-recommends --no-install-suggests ffmpeg yt-dlp python3 && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

COPY --from=build /app/ytsubs /app/ytsubs
EXPOSE 8080
CMD ["/app/ytsubs"]
