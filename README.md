FedoraRC

Experimental tool to run Fedora with OpenRC instead of systemd.
Main script: scripts/deliver-us-from-evil.sh

This repo has scripts and configs to bootstrap Fedora with 
OpenRC + elogind + netifrc instead of systemd.

Keeps systemd packages for DNF compatibility but removes 
runtime traces.

Repo structure:
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

Quick start:

Clone repo in /root:
git clone https://github.com/alamahant/fedorarc.git

Copy script:
cp fedorarc/scripts/deliver-us-from-evil.sh .

Run as root:
./deliver-us-from-evil.sh

Script will install dependencies, build OpenRC components,
configure system, and remove systemd runtime traces.

OpenRC commands:
rc-status - check service status
rc-service sshd start - start service
rc-update add sshd default - enable at boot

After install, edit /etc/default/grub and run:
grub2-mkconfig

Tested on Fedora. May work on RHEL derivatives.

Warning: Experimental. Test in VMs first.
