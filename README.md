FedoraRC - OpenRC for Fedora
---
This repository contains scripts and configuration snippets to bootstrap Fedora with OpenRC + elogind + netifrc instead of systemd.

Repository Structure
---
- scripts/       — installer and helper scripts (main: deliver-us-from-evil.sh)
- init.d/        — OpenRC init scripts
- conf.d/        — service configuration fragments
- tmpfiles/      — tmpfiles used during setup
- rules.d/       — udev rules
- grub/          — GRUB assets and templates
- config-files/  — shipped config snippets (e.g., /etc/default/grub, dracut conf, dnf config)
- LICENSE        — repository license

Quick Start
---
Clone repository in /root
git clone https://github.com/alamahant/fedorarc.git
---
Copy transformation script to /root
cp fedorarc/scripts/deliver-us-from-evil.sh .
---
Run as root
./deliver-us-from-evil.sh
---