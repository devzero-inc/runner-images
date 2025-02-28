# ScaleSet Images

These images are built to run as the scale set images for GitHub Actions Runner Controller. We install some pre-requisites and the runner binary.

## Building

Check the `Makefile` for commands to build, push, etc

### Caching Images in the Image

This example takes the approach of copying images in `./image-cache` to the container image, then on container startup via systemd we load those images into Docker daemon

To copy images run `docker image save $IMAGE:$TAG | gzip > ./image-cache/image-tag.tar.gz` then build the image `make build-ubuntu-latest`
