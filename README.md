FedoraRC

FedoraRC is an experimental tool to run Fedora with OpenRC instead of systemd.

Main script: scripts/deliver-us-from-evil.sh

This repository contains scripts, OpenRC init scripts, and configuration snippets to bootstrap a Fedora system to run with OpenRC + elogind + netifrc instead of systemd.

It focuses on making the conversion repeatable and safe by leaving systemd packages installed for DNF compatibility while removing runtime traces.

Repo layout:
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

scripts/ contains installer and helper scripts. Main script is scripts/deliver-us-from-evil.sh
init.d/ contains OpenRC init scripts
conf.d/ contains service configuration fragments
tmpfiles/ and rules.d/ contain tmpfiles and udev rules
grub/ contains grub assets and templates
config-files/ contains config snippets

Quick start:

Clone repository in /root:
git clone https://github.com/alamahant/fedorarc.git

Copy the script:
cp fedorarc/scripts/deliver-us-from-evil.sh .

Inspect and run as root:
./deliver-us-from-evil.sh

The script will install dependencies, build OpenRC components, configure the system, and remove systemd runtime traces.

Tested on Fedora, may work on RHEL derivatives.

OpenRC commands:
rc-status - check service status
rc-service sshd start - start service
rc-update add sshd default - enable service at boot

After installation, edit /etc/default/grub and regenerate grub config.

Warning: Experimental project. Test in VMs first.