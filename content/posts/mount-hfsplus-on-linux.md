---
title: "Mounting HFS+ Volumes on Ubuntu"
date: 2019-01-01T13:15:29-04:00
tags: ["Linux"]
draft: false
---

I recently had a need to transfer a large amount of data between a Linux and OSX host.
Isn't big data fun!
This is easiest to do from the Linux side, of course; I followed the directions [here](https://askubuntu.com/questions/332315/how-to-read-and-write-hfs-journaled-external-hdd-in-ubuntu-without-access-to-os), and am just recording the steps I followed here for posterity.

Install `hfsprogs`:

```shell
sudo apt-get install hfsprogs
```

Ubuntu can read, but not write (by default) to HFS+ drives, so they'll need to be remounted.
Usually the mount point lives under /media/USERNAME/:

```
sudo mount -t hfsplus -o remount,force,rw /media/jgoldfar/Untitled/
```

This didn't work for me (the resulting disk was not writable, despite the output from `mount` reporting the correct mount options.
Mounting the drive as below

```
sudo mkdir -p /media/jgoldfar/Untitled
sudo mount -t hfsplus -o force,rw /dev/sdb2 /media/jgoldfar/Untitled/
```

_Note_ You'll have to find the correct device under `/dev/`: the easiest way I could think to do that is to check the output of `ls -l /dev/sd*` for a device that was created around the correct time, and check the volume using e.g. `sudo fsck.hfsplus -f /dev/sdb2`.