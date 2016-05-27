#! /bin/bash

docker build -f Dockerfile.centos7:base -t rickalm/centos7:base .
docker build -f Dockerfile.centos7:dind-systemd -t rickalm/centos7:dind-systemd .
docker build -f Dockerfile.centos7:systemd-dind -t rickalm/centos7:systemd-dind .
