FROM rust:latest AS builder
WORKDIR /usr/working/

RUN apt update && yes | apt install python3 python3-pip git

RUN rm /usr/lib/python3.11/EXTERNALLY-MANAGED && pip install git+https://github.com/joshainglis/migra.git psycopg2-binary~=2.9.3
