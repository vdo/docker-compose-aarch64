# docker-compose binaries for aarch64

This repository contains helpers to build a docker-compose binary for aarch64/arm64. This project exists because, currently, docker-compose [releases](https://github.com/docker/compose/releases) do not include an aarch64 binary.

## Prepare cross build environment


```
docker run --rm --privileged multiarch/qemu-user-static:register
```

## To build

```bash
docker build . -t docker-compose-aarch64-builder
docker run --rm -v "$(pwd)":/dist docker-compose-aarch64-builder
# this will generate a `docker-compose-Linux-aarch64` in "$(pwd)"
```

## References

https://www.ecliptik.com/Cross-Building-and-Running-Multi-Arch-Docker-Images/#multiarch-on-linux
