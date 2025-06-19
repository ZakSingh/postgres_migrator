FROM rust:latest AS builder

WORKDIR /usr/src/
RUN apt update && apt install -y build-essential pkg-config libssl-dev

RUN USER=root cargo new postgres_migrator
WORKDIR /usr/src/postgres_migrator
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release

COPY src ./src
RUN cargo install --path .


FROM python:alpine
RUN apk add git
RUN pip install git+https://github.com/joshainglis/migra.git psycopg2-binary~=2.9.3 setuptools

COPY --from=builder /usr/local/cargo/bin/postgres_migrator /usr/bin/

WORKDIR /working

ENTRYPOINT ["/usr/bin/postgres_migrator"]
