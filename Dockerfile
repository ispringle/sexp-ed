FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    guile-3.0 \
    guile-3.0-dev \
    make \
    gcc \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Haunt from source (not in Debian repos)
RUN curl -L https://files.dthompson.us/haunt/haunt-0.3.0.tar.gz -o /tmp/haunt.tar.gz && \
    cd /tmp && \
    tar xzf haunt.tar.gz && \
    cd haunt-0.3.0 && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    rm -rf /tmp/haunt*

WORKDIR /site

# Default command is to build the site
CMD ["haunt", "build"]
