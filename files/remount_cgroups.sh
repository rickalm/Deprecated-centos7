#!/bin/bash

# If /remount_cgroups.done exists then we have already done our job and return
#
[ -f /tmp/remount_cgroups.done ] && exit 0

# Taken from https://github.com/jpetazzo/dind
#
# Ensure that all nodes in /dev/mapper correspond to mapped devices currently loaded by the device-mapper kernel driver
dmsetup mknodes

# First, make sure that cgroups are mounted correctly.
CGROUP=/sys/fs/cgroup
: {LOG:=stdio}

[ -d $CGROUP ] ||
	mkdir $CGROUP

mountpoint -q $CGROUP ||
	mount -n -t tmpfs -o uid=0,gid=0,mode=0755 cgroup $CGROUP || {
		echo "Could not make a tmpfs mount. Did you use --privileged?"
		exit 1
	}

if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security; then
  mount -t securityfs none /sys/kernel/security || {
      echo "Could not mount /sys/kernel/security."
      echo "AppArmor detection and --privileged mode might break."
  }
fi

# Mount the cgroup hierarchies exactly as they are in the parent system.
for SUBSYS in $(cut -d: -f2 /proc/1/cgroup); do

  # create target if doesnt exist
  #
  [ -d $CGROUP/$SUBSYS ] || mkdir $CGROUP/$SUBSYS

  # unless already mounted, create cgroup mount
  #
  mountpoint -q $CGROUP/$SUBSYS ||
    mount -n -t cgroup -o $SUBSYS cgroup $CGROUP/$SUBSYS

  # The two following sections address a bug which manifests itself
  # by a cryptic "lxc-start: no ns_cgroup option specified" when
  # trying to start containers within a container.
  #
  # The bug seems to appear when the cgroup hierarchies are not
  # mounted on the exact same directories in the host, and in the
  # container.

  # Named, control-less cgroups are mounted with "-o name=foo"
  # (and appear as such under /proc/<pid>/cgroup) but are usually
  # mounted on a directory named "foo" (without the "name=" prefix).
  # Systemd and OpenRC (and possibly others) both create such a
  # cgroup. To avoid the aforementioned bug, we symlink "foo" to
  # "name=foo". This shouldn't have any adverse effect.
  #
  echo $SUBSYS | grep -q ^name= && {
    NAME=$(echo $SUBSYS | sed s/^name=//)
    ln -s $SUBSYS $CGROUP/$NAME
  }

  # Likewise, on at least one system, it has been reported that
  # systemd would mount the CPU and CPU accounting controllers
  # (respectively "cpu" and "cpuacct") with "-o cpuacct,cpu"
  # but on a directory called "cpu,cpuacct" (note the inversion
  # in the order of the groups). This tries to work around it.
  #
  [ $SUBSYS = cpuacct,cpu ] && ln -s $SUBSYS $CGROUP/cpu,cpuacct
done

# Note: as I write those lines, the LXC userland tools cannot setup
# a "sub-container" properly if the "devices" cgroup is not in its
# own hierarchy. Let's detect this and issue a warning.

grep -q :devices: /proc/1/cgroup ||
	echo "WARNING: the 'devices' cgroup should be in its own hierarchy."

grep -qw devices /proc/1/cgroup ||
	echo "WARNING: it looks like the 'devices' cgroup is not mounted."

# ok, create our flag file so we dont run again
#
touch /tmp/remount_cgroups.done
