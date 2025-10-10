# FedoraRC

**FedoraRC** — experimental tooling to run Fedora with **OpenRC**
instead of systemd.

> Deliver us from evil.  
> Main script: `scripts/deliver-us-from-evil.sh`

---

## What this repo is

This repository contains scripts, OpenRC init scripts, and
configuration snippets to bootstrap a Fedora system (and likely
other RHEL-derived distributions) to run with **OpenRC + elogind +
netifrc** instead of systemd.

It focuses on making the conversion repeatable and (relatively) safe
by leaving systemd packages installed for DNF compatibility while
removing runtime/system traces.

---

## Repo layout

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

- `scripts/` — installer and helper scripts. The main entrypoint is:
  - `scripts/deliver-us-from-evil.sh` — the primary automation
    script (tested on Fedora; may work on RHEL derivatives).
- `init.d/` — OpenRC init scripts (will be enriched over time).
- `conf.d/` — service configuration fragments (growing collection).
- `tmpfiles/` and `rules.d/` — tmpfiles and udev rules used during
  setup.
- `grub/` — grub assets and templates used by the installer.
- `config-files/` — shipped config snippets (for example
  `/etc/default/grub`, dracut conf, dnf config).
- `LICENSE` — repository license.

---

## Quick start / usage

1. Clone repository in `/root` (if not already present):

   git clone https://github.com/alamahant/fedorarc.git

   Copy the transformation script to `/root`:

   cp fedorarc/scripts/deliver-us-from-evil.sh .

2. Inspect the main script and run it as **root** when ready:

   less deliver-us-from-evil.sh

   Run the script:

   ./deliver-us-from-evil.sh

3. The script will:

   - install build dependencies  
   - build & install OpenRC, elogind and netifrc  
   - optionally build dracut and create initramfs  
   - copy provided files into `/etc`, `/usr/lib/tmpfiles.d`,
     `/usr/lib/udev/rules.d`, etc.  
   - wipe systemd runtime traces while preserving `.so` libs for
     package compatibility  
   - configure OpenRC services and helper scripts  

Important: the installer detects container environments and skips
bootloader/bootconfig tasks inside containers.

---

## Tested platforms

- Tested: Fedora  
- Likely works on: RHEL and derivatives (CentOS Stream, AlmaLinux,
  Rocky, etc.) — but expect differences in package names, paths and
  dracut/grub tooling. Always inspect the script before running on
  production machines.

---

## Notes & future work

- `conf.d` and `init.d` directories will be enriched over time —
  more OpenRC scripts and config fragments will be added.  
- The repository intentionally does not uninstall systemd packages —
  it removes runtime traces and replaces init with OpenRC while
  keeping library compatibility to avoid breaking package
  management.  
- The main script will copy `fedorarc/config-files/*` into relevant
  system locations. Review those files before running.  

---

## OpenRC quick reference

# check status of all services
rc-status

# start / stop / restart a service
rc-service sshd start
rc-service sshd stop
rc-service sshd restart

# enable a service at boot (add to runlevel)
rc-update add sshd default

# disable a service at boot (remove from runlevel)
rc-update del sshd default

# list services in a runlevel
ls /etc/runlevels/default

# wrapper helpers included in repo (installed to /usr/local/bin):
rc start|stop|restart|reload|status svc1 svc2 ...
rcenable svc1 svc2 @default
rcdisable svc1 svc2 @default

---

## Bootloader / GRUB

After the script runs (on a non-container machine) you must:

1. Edit `/etc/default/grub` (the installer places a template there)
   to set your `root=` and `rootfstype=` values.  

2. Regenerate grub config:

   grub2-mkconfig -o /boot/grub2/grub.cfg --force

Or use whatever distribution-specific grub command is required.

---

## Contributing & safety

- This project is experimental. Test in VMs first.  
- Always inspect the contents of `fedorarc/` before running the
  installer on machines with important data. 