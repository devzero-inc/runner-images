ARG BASE_IMAGE=devzeroinc/gha-runner-image-ubuntu:22.04-devel

FROM ${BASE_IMAGE} AS initial

ARG ARCH=amd64
ARG RUNNER_VERSION=2.322.0
ARG RUNNER_USER_UID=1001

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:git-core/ppa \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
    systemd \
    systemd-sysv \
    libsystemd0 \
    ca-certificates \
    dbus \
    iptables \
    iproute2 \
    kmod \
    locales \
    sudo \
    curl \
    git \
    vim \
    nano \
    ssh \
    ssh \
    build-essential \
    htop \
    dnsutils \
    net-tools \
    less \
    wget \
    zip \
    unzip \
    udev \
    jq


# Download latest git-lfs version
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y --no-install-recommends git-lfs

RUN adduser --disabled-password --gecos "" --uid $RUNNER_USER_UID runner \
    && usermod -aG sudo runner \
    && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

# Create docker group and add runner user to it
RUN groupadd docker || true \
    && usermod -aG docker runner

# Enable sshing in
RUN systemctl enable ssh

RUN echo "runner:runner" | chpasswd

ENV HOME=/home/runner
ENV RUNNER_ASSETS_DIR=/runner

RUN mkdir -p "${RUNNER_ASSETS_DIR}" && chown -R runner:runner "${RUNNER_ASSETS_DIR}"

USER runner
RUN if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "i386" ]; then export ARCH=x64 ; fi \
    && cd "$RUNNER_ASSETS_DIR" \
    && umask 000 \
    && curl -fLo runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./runner.tar.gz \
    && rm runner.tar.gz \
    && sudo ./bin/installdependencies.sh \
    && sudo apt-get install -y libyaml-dev

RUN cd "${RUNNER_ASSETS_DIR}" \
    && curl -f -L -o runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v0.6.2/actions-runner-hooks-k8s-0.6.2.zip \
    && unzip ./runner-container-hooks.zip -d ./k8s \
    && rm runner-container-hooks.zip

ENV RUNNER_TOOL_CACHE=/opt/hostedtoolcache
RUN sudo mkdir -p /opt/hostedtoolcache \
    && sudo chown -R runner:runner /opt/hostedtoolcache \
    && sudo chmod -R g+rwx /opt/hostedtoolcache

USER root

RUN update-alternatives --set iptables /usr/sbin/iptables-legacy \
    && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

COPY github-runner.service /etc/systemd/system/github-runner.service

RUN systemctl enable github-runner

RUN systemctl mask systemd-modules-load.service \
    systemd-resolved.service \
    unattended-upgrades.service

# trying multi-stage build, but if you have a very large base image it won't help much
# FROM scratch
# COPY --from=initial / /
ARG CACHEBUST
RUN echo ${CACHEBUST}
ENV CACHEBUST=${CACHEBUST}

ARG DZ_TAR=dz.tar.gz
RUN wget -O ${DZ_TAR} https://get.devzero.io/stable/linux-${ARCH}/dz.tar.gz \
    && tar -xzf ${DZ_TAR} \
    && rm -rf ${DZ_TAR} \
    && mv dzcmd /usr/bin
RUN chmod +x /usr/bin/dzcmd
RUN ln -s /usr/bin/dzcmd /usr/bin/dzboot

STOPSIGNAL SIGRTMIN+3
ENV DZBOOT_SKIP_PERSIST="1"

COPY ./cache /cache
COPY docker-image-loader.service /etc/systemd/system/docker-image-loader.service
COPY docker-image-loader.sh /scripts/docker-image-loader.sh

RUN systemctl enable docker-image-loader
