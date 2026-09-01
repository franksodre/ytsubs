FROM ubuntu:26.04 AS build

RUN apt update && \
  apt install -y --no-install-recommends --no-install-suggests git build-essential ca-certificates && \
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

# RUN apt update && \
#   apt install -y --no-install-recommends --no-install-suggests ffmpeg python3 ca-certificates curl && \
#   update-ca-certificates && \
#   curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/bin/yt-dlp && \
#   chmod a+rx /usr/bin/yt-dlp && \
#   rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    curl \
    7zip \
    ca-certificates \
    python3-pip \
    ffmpeg \
    jq \
    && pip3 install --break-system-packages yt-dlp[default] && \
    rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deno.land/install.sh | sh
ENV PATH="/root/.deno/bin:$PATH"

WORKDIR /app
COPY . .

COPY --from=build /app/ytsubs /app/ytsubs
EXPOSE 8080
CMD ["/app/ytsubs"]
