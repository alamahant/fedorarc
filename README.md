FedoraRC

FedoraRC is an experimental project that transforms Fedora
and related distributions to run with OpenRC, elogind, and netifrc
instead of systemd. Its goal is to provide an alternative init
framework while keeping compatibility with Fedora’s package
management and runtime environment.

This repository contains configuration files, init scripts,
and utilities to integrate OpenRC into Fedora-based systems.
It is meant for advanced users who understand the risks of
replacing systemd and want to explore a fully OpenRC-based
environment.

More OpenRC service scripts and config files will be added
over time to   INIT.D   and   CONF.D   to support daemons
installed with DNF. If a daemon or configuration is missing,
please open an issue so it can be added in future updates.

For setup and usage instructions, read INSTRUCTIONS.txt
and OPENRC.txt in this repository.

© 2025 Alamahant. All rights reserved.