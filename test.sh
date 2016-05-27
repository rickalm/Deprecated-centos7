docker rm -f dind-test

[ -z "$1" ] && D=-d
docker run --privileged -it --net=host --name=dind-test $D \
  rickalm/centos7:dind-systemd $@

docker exec -it dind-test /bin/bash
