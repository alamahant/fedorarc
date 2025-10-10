FedoraRC

FedoraRC is an experimental project that lets you run Fedora using OpenRC as the init system instead of systemd. The main script that handles this transformation is called deliver-us-from-evil.sh and can be found in the scripts directory.
Overview

This repository provides all the necessary components to convert a Fedora system over to OpenRC with elogind for session management and netifrc for network interface control. The approach keeps systemd packages installed to maintain compatibility with DNF and other system tools, but removes all runtime traces of systemd so your system actually boots and runs with OpenRC.
Repository Structure

    conf.d - service configuration fragments

    init.d - OpenRC service scripts

    tmpfiles/ and rules.d/ - tmpfiles and udev rules

    grub/ - boot configuration assets

    config-files/ - system configuration snippets

    scripts/ - installation and helper scripts

Quick Start

    Clone the repository:

bash

git clone https://github.com/alamahant/fedorarc.git

    Copy the transformation script:

bash

cp fedorarc/scripts/deliver-us-from-evil.sh .

    Review and run as root:

bash

./deliver-us-from-evil.sh

The script handles everything from installing build dependencies to compiling and setting up OpenRC, elogind, and netifrc. It creates a proper initramfs and removes systemd from the boot process while keeping necessary libraries for package compatibility.
OpenRC Commands

    rc-status - check service status

    rc-service sshd start - start a service

    rc-update add sshd default - enable service at boot

Post-Installation

After conversion, update your GRUB configuration:

    Edit /etc/default/grub to set your root device

    Regenerate GRUB config: grub2-mkconfig

Compatibility

Tested on Fedora. Likely works on RHEL derivatives like CentOS Stream, AlmaLinux, and Rocky Linux, though some adjustments might be needed.

Warning: This is experimental software - always test in a virtual machine or on non-critical hardware first.