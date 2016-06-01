#! /bin/bash

# Since these are built by hub.docker.com, no need to build locally anymore
# but as a backup if they cannot be pulled then create locally
#
[ -n "$1" ] && rev=-${1}

docker pull rickalm/centos7:base${rev} ||
  ( echo Building rickalm/centos7:base${rev} locally && 
    docker build -f Dockerfile.centos7:base -t rickalm/centos7:base${rev} . )

docker pull rickalm/centos7-dind:dind-systemd${rev} || 
  ( echo Building rickalm/centos7-dind:dind-systemd${rev} locally && 
    docker build -f Dockerfile.centos7-dind:dind-systemd${rev} -t rickalm/centos7-dind:dind-systemd${rev} . )

docker pull rickalm/centos7-dind:systemd-dind${rev} ||
  ( echo Building rickalm/centos7-dind:systemd-dind${rev} locally && 
    docker build -f Dockerfile.centos7-dind:systemd-dind${rev} -t rickalm/centos7-dind:systemd-dind${rev} . )
