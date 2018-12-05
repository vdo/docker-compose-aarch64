# Dockerfile to build docker-compose for aarch64
FROM multiarch/ubuntu-core:arm64-bionic

# Add env
ENV LANG C.UTF-8

# Enable cross-build for aarch64
COPY ./vendor/qemu-bin /usr/bin/
RUN [ "cross-build-start" ]

# Set the versions
ENV DOCKER_COMPOSE_VER 1.22.0
# docker-compose requires pyinstaller 3.3.1 (check github.com/docker/compose/requirements-build.txt)
# If this changes, you may need to modify the version of "six" below
ENV PYINSTALLER_VER 3.3.1
# "six" is needed for PyInstaller. v1.11.0 is the latest as of PyInstaller 3.3.1
ENV SIX_VER 1.11.0

# Install dependencies
RUN apt-get update && apt-get install -y python3 python3-pip git zlib1g-dev curl
RUN pip3 install six==$SIX_VER

# Compile the pyinstaller "bootloader"
# https://pyinstaller.readthedocs.io/en/stable/bootloader-building.html
WORKDIR /build/pyinstallerbootloader
RUN curl -fsSL https://github.com/pyinstaller/pyinstaller/releases/download/v$PYINSTALLER_VER/PyInstaller-$PYINSTALLER_VER.tar.gz | tar xvz >/dev/null \
    && cd PyInstaller*/bootloader \
    && python3 ./waf all

# Clone docker-compose
WORKDIR /build/dockercompose
RUN git clone https://github.com/docker/compose.git . \
    && git checkout $DOCKER_COMPOSE_VER

# Run the build steps (taken from github.com/docker/compose/script/build/linux-entrypoint)
RUN mkdir ./dist \
    && pip3 install -q -r requirements.txt -r requirements-build.txt \
    && ./script/build/write-git-sha \
    && pyinstaller docker-compose.spec \
    && mv dist/docker-compose ./docker-compose-$(uname -s)-$(uname -m)

# Disable cross-build for aarch64
# Note: don't disable this, since we want to run this container on x86_64, not aarch64
# RUN [ "cross-build-end" ]

# Copy out the generated binary
VOLUME /dist
CMD cp docker-compose-* /dist
