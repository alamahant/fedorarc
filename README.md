FedoraRC - OpenRC for Fedora

This repository contains scripts and configurations to bootstrap Fedora with OpenRC + elogind + netifrc instead of systemd.
Repository Structure

fedorarc/
conf.d
config-files
grub
init.d
LICENSE
README.md
rules.d
scripts
tmpfiles
Quick Start

    Clone repo in /root:
    git clone https://github.com/alamahant/fedorarc.git

    Copy script to /root:
    cp fedorarc/scripts/deliver-us-from-evil.sh .

    Run as root:
    ./deliver-us-from-evil.sh

Script will install dependencies, build OpenRC components, configure system, and remove systemd runtime traces.
Compatibility

Tested on Fedora. May work on RHEL derivatives.
Warning

Experimental. Test in VMs first.