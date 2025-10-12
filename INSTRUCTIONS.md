FedoraRC - OpenRC for Fedora

This repository contains scripts and configurations to bootstrap Fedora with OpenRC + elogind + netifrc instead of systemd.
🚀 How to Use

First create a Fedora minimal VM or Incus container.

Disable Selinux in /etc/selinux/config and either stop firewalld or open port 22 for SSH.
Especially for SELinux, it is ESSENTIAL that you keep it disabled or permissive until a policy solution is set.

Then, from within that VM:


# Clone the repository in /root folder
cd /root
git clone https://github.com/alamahant/fedorarc.git

# Copy the transformation script to /root
cp fedorarc/scripts/deliver-us-from-evil.sh /root/

# Run as root
chmod +x deliver-us-from-evil.sh
./deliver-us-from-evil.sh

The script will install dependencies, build OpenRC components, configure the system, and remove systemd runtime traces.
🔄 Dual Boot Option
IMPORTANT UPDATE

A new script named coexist-with-evil.sh was added to enable dual boot between OpenRC and systemd.

If you wish to explore this scenario, please use:


./coexist-with-evil.sh

instead of:


./deliver-us-from-evil.sh

🎯 Init System Selector


After running coexist-with-evil.sh, a convenient script is installed at:


/usr/local/bin/select_init

Usage:

# Run the init selector

select_init openrc
select_init systemd

Features:

    Easily select your init system

    Changes take effect on next boot

    No complex configuration editing required

    Perfect for testing and development environments

📦 After Installation

If you install a package with a daemon using DNF:

    Look in init.d/services/ - if its script is found there, move it to init.d/

    Check conf.d/config/ - if its configuration file is found there, move it to conf.d/

    Test the service

If you encounter any problems, please open an issue. Also open an issue if your desired daemon and configuration are missing from the existing files.
🔧 Compatibility

    ✅ Tested on Fedora

    ⚠️ May also work on RHEL derivatives

⚠️ Warning

This project is experimental.
Always test in virtual machines or Incus containers before committing to bare metal.

© 2025 Alamahant. All rights reserved.