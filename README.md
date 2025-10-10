# FedoraRC

FedoraRC — experimental tooling to run Fedora with OpenRC instead of systemd.

Deliver us from evil.
Main script: scripts/deliver-us-from-evil.sh

---

What this repo is

This repository contains scripts, OpenRC init scripts, and configuration snippets to bootstrap a Fedora system (and likely other RHEL-derived distributions) to run with OpenRC + elogind + netifrc instead of systemd.

It focuses on making the conversion repeatable and (relatively) safe by leaving systemd packages installed for DNF compatibility while removing runtime/system traces.

---

Repo layout

fedorarc/
├── conf.d
├── config-files
├── grub
├── init.d
├── LICENSE
├── README.md
├── rules.d
├── scripts
└── tmpfiles

- scripts/ — installer and helper scripts. Main entrypoint:
  - scripts/deliver-us-from-evil.sh — primary automation script (tested on Fedora; may work on RHEL derivatives).
- init.d/ — OpenRC init scripts (will be enriched over time).
- conf.d/ — service configuration fragments.
- tmpfiles/ and rules.d/ — tmpfiles and udev rules used during setup.
- grub/ — grub assets and templates used by the installer.
- config-files/ — config snippets (e.g., /etc/default/grub, dracut conf, dnf config).
- LICENSE — repository license.

---

Quick start / usage

1. Clone repository in /root:

git clone https://github.com/alamahant/fedorarc.git

Copy the transformation script to /root:

cp fedorarc/scripts/deliver-us-from-evil.sh .

2. Inspect the main script and run it as root when ready:

less deliver-us-from-evil.sh

Run the script:

./deliver-us-from-evil.sh

3. The script will:

- install build dependencies
- build & install OpenRC, elogind and netifrc
- optionally build dracut and create initramfs
- copy provided files into /etc, /usr/lib/tmpfiles.d, /usr/lib/udev/rules.d, etc.
- wipe systemd runtime traces while preserving .so libs for package compatibility
- configure OpenRC services and helper scripts

Important: the installer detects container environments and skips bootloader/bootconfig tasks inside containers.

---

Tested platforms

- Tested: Fedora
- Likely works on: RHEL and derivatives (CentOS Stream, AlmaLinux, Rocky, etc.) — differences in package names, paths, dracut/grub tooling may exist. Inspect the script before running on production machines.

---

Notes & future work

- conf.d and init.d directories will be enriched over time — more OpenRC scripts and config fragments will be added.
- The repository does not uninstall systemd packages — it removes runtime traces and replaces init with OpenRC while keeping library compatibility.
- The main script will copy fedorarc/config-files/* into relevant system locations. Review before running.

---

OpenRC quick reference

check status of all services

rc-status

start / stop / restart a service

rc-service sshd start
rc-service sshd stop
rc-service sshd restart

enable a service at boot

rc-update add sshd default

disable a service at boot

rc-update del sshd default

list services in a runlevel

ls /etc/runlevels/default

wrapper helpers installed to /usr/local/bin

rc start|stop|restart|reload|status svc1 svc2 ...

rcenable svc1 svc2 
rcdisable svc1 svc2 

---

Bootloader / GRUB

After the script runs (non-container machine) you must:

1. Edit /etc/default/grub to set your root= and rootfstype= values.
2. Regenerate grub config:

grub2-mkconfig -o /boot/grub2/grub.cfg --force

or use whatever distro-specific grub command is required.

---

Contributing & safety

- Experimental project. Test in VMs first.
- Inspect fedorarc/ before running on machines with important data.