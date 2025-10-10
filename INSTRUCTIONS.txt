FedoraRC - OpenRC for Fedora

This repository contains scripts and configurations to bootstrap Fedora
with OpenRC + elogind + netifrc instead of systemd.

How to Use

Clone repository in /root:
cd /root
git clone https://github.com/alamahant/fedorarc.git

Copy the transformation script to /root:
cp fedorarc/scripts/deliver-us-from-evil.sh /root/

Run as root:
chmod +x deliver-us-from-evil.sh
./deliver-us-from-evil.sh

Script will install dependencies, build OpenRC components,
configure the system, and remove systemd runtime traces.

Compatibility

Tested on Fedora. May work on RHEL derivatives.

Warning:

Experimental. Test in VMs first.