# centos7
Docker container based on CentOS:7 with SystemD and Docker in Docker configured

These repos are intended for projects which require a CentOS 7 environment with SystemD and Docker. This allows the creation of a container encapsulating any tools intended to run on a CentOS 7 VM with full Docker and SystemD unit file support. 

There are three build artifacts as a result of this repo

- centos7:base
  - Base image the images below are based on
  
- centos7:dind-systemd
  - Starts Docker, then passes control to SystemD
  
- centos7:systemd-dind
  - Starts SystemD and Docker launches as a service
