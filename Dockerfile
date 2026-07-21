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

FROM ubuntu:26.04 AS run

WORKDIR /app
COPY . .

RUN apt update && \
  apt install -y --no-install-recommends --no-install-suggests ffmpeg python3 && \
  # curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/bin/yt-dlp && \
  # chmod a+rx /usr/bin/yt-dlp && \
  rm -rf /var/lib/apt/lists/* && \

RUN chmod a+rx /app/bin/yt-dlp

COPY --from=build /app/ytsubs /app/ytsubs
EXPOSE 8080
CMD ["/app/ytsubs"]
