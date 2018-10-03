#
# Docker configuration to set up a Ubuntu 16.04 image with Media Cloud
# dependencies preinstalled for CI to pull and use later.
#

FROM buildpack-deps:xenial

ENV DEBIAN_FRONTEND noninteractive

COPY mediacloud/ansible/ /mediacloud-ansible/

RUN \
    apt-get -y update && \
    apt-get -y --no-install-recommends install apt-utils && \
    apt-get -y --no-install-recommends install apt-transport-https && \
    apt-get -y --no-install-recommends install acl && \
    apt-get -y --no-install-recommends install sudo && \
    apt-get -y --no-install-recommends install build-essential ca-certificates file python3-dev python3-pip python3-setuptools && \
    apt-get -y --no-install-recommends install apache2 libapache2-mod-fcgid && \
    apt-get -y clean && \
    \
    pip3 install --upgrade pip && \
    # https://github.com/pypa/pip/issues/5221#issuecomment-382069604
    hash -r pip3 && \
    pip3 install --upgrade ansible && \
    rm -rf /root/.cache/ && \
    \
    mkdir /root/mediacloud/ && \
    mv /mediacloud-ansible /root/mediacloud/ansible/

WORKDIR /root

RUN \
    cd mediacloud/ansible/ && \
    \
    ansible-playbook \
    --inventory="localhost," \
    --connection=local \
    -vvv travis.yml && \
    \
    rm -rf /root/mediacloud/ && \
    rm -rf /root/.cache/ && \
    rm -rf /root/.cpanm/ && \
    apt-get -y clean
