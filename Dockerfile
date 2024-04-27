# Define the base image
FROM debian:buster as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    automake \
    asciidoc \
    build-essential \
    libtool \
    gettext \
    git

# Clone the Tinyproxy repository
RUN git clone https://github.com/tinyproxy/tinyproxy.git /tinyproxy
WORKDIR /tinyproxy

# Build Tinyproxy from source
RUN ./autogen.sh
RUN ./configure --enable-transparent --prefix=/usr
RUN make && make install

# Start a new clean stage to reduce image size
FROM debian:buster
COPY --from=builder /usr/bin/tinyproxy /usr/bin/tinyproxy
COPY --from=builder /usr/share/tinyproxy /usr/share/tinyproxy

# Copy the custom configuration file
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Expose the default Tinyproxy port
EXPOSE 8888

# Run Tinyproxy in the foreground
CMD ["tinyproxy", "-d"]
