FROM rust:latest AS builder
# Install musl toolchain

WORKDIR /usr/src/
RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
RUN apt-get install -y build-essential
RUN yes | apt install gcc-x86-64-linux-gnu

RUN USER=root cargo new postgres_migrator
WORKDIR /usr/src/postgres_migrator
COPY Cargo.toml Cargo.lock ./
ENV RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc'
RUN cargo build --target x86_64-unknown-linux-musl --release

COPY src ./src
RUN cargo install --target x86_64-unknown-linux-musl --path .


FROM python:alpine
RUN apk add git
RUN pip install git+https://github.com/joshainglis/migra.git psycopg2-binary~=2.9.3 setuptools

COPY --from=builder /usr/local/cargo/bin/postgres_migrator /usr/bin/

WORKDIR /working

ENTRYPOINT ["/usr/bin/postgres_migrator"]
