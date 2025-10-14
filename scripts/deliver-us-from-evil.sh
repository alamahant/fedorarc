#!/bin/bash
set -e

BUILD_DIR="/root/builds"
mkdir -p $BUILD_DIR 

# ---------------------------
# Download and install packages
# ---------------------------
download_packages() {
    echo "[*] Updating system and installing base packages..."
    dnf update -y

    dnf install -y \
        git gcc make cmake meson ninja-build pkgconfig \
        wget curl tar bzip2 gzip xz \
        vim nano \
        iproute iputils net-tools \
        openssh-server openssh-clients \
        cronie rsyslog \
        dbus dbus-devel dbus-daemon polkit-devel \
        sudo util-linux shadow zstd lz4 cpio

    dnf install -y \
        libudev-devel \
        systemd-devel libcap-devel pam-devel \
        libselinux-devel gperf python3-jinja2 asciidoc kmod-devel \
        xfsprogs btrfs-progs e2fsprogs lvm2

    dnf install -y cronie rsyslog dhcpcd nano vim grub2-efi-x64-modules
}

# ---------------------------
# Build OpenRC
# ---------------------------
build_openrc() {
    echo "[*] Building OpenRC..."
    cd "$BUILD_DIR"
    rm -rf openrc || true
    [ ! -d openrc ] && git clone https://github.com/OpenRC/openrc.git
    cd openrc

    mkdir -p build && cd build
    meson .. --prefix=/usr
    ninja
    DESTDIR= ninja install   # required or install fails
    ln -sf /usr/sbin/openrc-init /sbin/init
}

# ---------------------------
# Build elogind
# ---------------------------
build_elogind() {
    echo "[*] Building elogind..."
    cd "$BUILD_DIR"
    rm -rf elogind || true
    [ ! -d elogind ] && git clone https://github.com/elogind/elogind.git
    cd elogind
    mkdir -p build && cd build
    meson setup .. --prefix=/usr --buildtype=release
    ninja
    ninja install
}

# ---------------------------
# Build netifrc
# ---------------------------
build_netifrc() {
    echo "[*] Building netifrc..."
    cd "$BUILD_DIR"
    rm -rf netifrc || true
    [ ! -d netifrc ] && git clone https://github.com/gentoo/netifrc.git
    cd netifrc
    make
    make install
    echo "[*] netifrc installed. Link interfaces manually if needed."
}

# ---------------------------
# Wipe systemd
# ---------------------------
wipe_systemd() {
    echo "[*] Backing up libsystemd* and libudev*..."
    mkdir -p /root/lib-backup
    cp -av /usr/lib64/libsystemd* /root/lib-backup/ 2>/dev/null || true
    cp -av /usr/lib64/libudev* /root/lib-backup/ 2>/dev/null || true

    echo "[*] Wiping systemd binaries..."
    rm -fv /usr/bin/systemctl /usr/bin/journalctl /usr/bin/loginctl
    rm -fv /usr/sbin/systemd
    rm -fv /usr/lib/systemd/systemd
    rm -fv /bin/systemd /sbin/systemd
    rm -fv /usr/bin/systemd /usr/sbin/systemd

    echo "[*] Removing systemd directories..."
    rm -rfv /etc/systemd
    rm -rfv /usr/lib/systemd
    rm -rfv /run/systemd
    rm -rfv /var/lib/systemd
    rm -rfv /var/cache/systemd
    rm -rfv /var/log/journal
    rm -rfv /tmp/systemd-* /var/tmp/systemd-*

    echo "[*] Removing tmpfiles/sysusers stubs..."
    rm -rfv /usr/lib/tmpfiles.d/systemd*
    rm -rfv /usr/lib/sysusers.d/systemd*
    rm -rfv /etc/tmpfiles.d/systemd*
    rm -rfv /etc/sysusers.d/systemd*
    rm -rfv /usr/lib/udev/rules.d/*

    echo "[*] Restoring libsystemd* and libudev*..."
    cp -av /root/lib-backup/libsystemd* /usr/lib64/ 2>/dev/null || true
    cp -av /root/lib-backup/libudev* /usr/lib64/ 2>/dev/null || true

    echo "[*] Systemd completely wiped (binaries, dirs, cache, tmp)."
}

# ---------------------------
# Copy needed files
# ---------------------------
copy_needed_files() {
    echo "[*] Extracting needed files..."
    cd ~
if [ ! -d fedorarc ];then
    if [ -f fedorarc.tar.gz ]; then
        tar -xf fedorarc.tar.gz
    else
        echo "[!] cloned fedorarc or fedorarc.tar.gz not found in $BUILD_DIR"
        return 1
    fi
fi
    echo "[*] Copying init.d scripts..."
    cp -av fedorarc/init.d/* /etc/init.d/ 2>/dev/null || true

    echo "[*] Copying conf.d configs..."
    cp -av fedorarc/conf.d/* /etc/conf.d/ 2>/dev/null || true

    echo "[*] Copying tmpfiles.d rules..."
    cp -av fedorarc/tmpfiles.d/* /usr/lib/tmpfiles.d/ 2>/dev/null || true

    echo "[*] Copying udev rules..."
    cp -av fedorarc/rules.d/* /usr/lib/udev/rules.d/ 2>/dev/null || true

    echo "[*] Copying user scripts..."
    cp -av fedorarc/scripts/rc* /usr/local/bin/ 2>/dev/null || true

    echo "[*] Creating aliases..."
    mkdir -p /etc/bash/bashrc.d || true
    cp -av fedorarc/config-files/*.bash /etc/bash/bashrc.d/ 2>/dev/null || true

    cat <<'EOF' >> /etc/bashrc

### Custom bashrc.d support ###
# Create directory if it does not exist
[ ! -d "/etc/bash/bashrc.d" ] && mkdir -p /etc/bash/bashrc.d

# Source all readable .bash or .sh files in bashrc.d
for _ in /etc/bash/bashrc.d/*; do
    if [[ $_ == *.@(bash|sh) && -r $_ ]]; then
        source "$_"
    fi
done
EOF



    echo "[*] Copying other files..."
    cp -av fedorarc/config-files/etc-dnf-dnf-conf /etc/dnf/dnf.conf 2>/dev/null || true
    cp -av fedorarc/config-files/etc-default-grub /etc/default/grub 2>/dev/null || true

    mkdir -p /etc/dracut.conf.d 
    cp -av fedorarc/config-files/dracut-fedorarc.conf /etc/dracut.conf.d/fedorarc.conf 2>/dev/null || true

    echo "[*] Needed files installed."
}

# ---------------------------
# Reset udev runtime and apply new rules
# ---------------------------
reset_udev() {
    if grep -q 'container=' /proc/1/environ 2>/dev/null; then
        echo "Container detected"
        return 0
    fi

    cd ~
    echo "[*] Cleaning systemd leftovers from /tmp and /var/tmp..."
    rm -rfv /tmp/systemd-* /var/tmp/systemd-* 2>/dev/null || true

    echo "[*] Resetting udev runtime and reloading rules..."
    if rc-service udev status >/dev/null 2>&1; then
        rc-service udev stop || true
    fi

    rm -rfv /run/udev/* /var/lib/udev/* /var/run/udev/* 2>/dev/null || true

    # Apply new tmpfiles and rules
    if [ -d "fedorarc/tmpfiles.d" ]; then
        cp -av "fedorarc/tmpfiles.d/"* /usr/lib/tmpfiles.d/
    fi
    if [ -d "fedorarc/rules.d" ]; then
        cp -av "fedorarc/rules.d/"* /usr/lib/udev/rules.d/
    fi

    rc-service udev start || true

    udevadm control --reload || true
    udevadm trigger --type=subsystems --action=add || true
    udevadm trigger --type=devices --action=add || true
    udevadm settle || true

    # Safety symlink in case something expects udevd
    mkdir -p /usr/lib/systemd
    ln -sf /usr/sbin/udevadm /usr/lib/systemd/systemd-udevd

    echo "[*] udev reset complete and systemd tmp cleaned."
}

# ---------------------------
# Perform tasks
# ---------------------------
perform_tasks() {
    echo "=== Creating agetty symlinks and enabling terminals ==="
    for tty in 1 2 3 4 5 6; do
        ln -sf /etc/init.d/agetty /etc/init.d/agetty.tty${tty}
        rc-update add agetty.tty${tty} default || true
    done

    echo "=== Linking network interfaces and enabling net.eth0 ==="
    ln -sf /etc/init.d/net.lo /etc/init.d/net.eth0
    rc-update add net.eth0 default
    rm -f /etc/resolv.conf
    echo "nameserver 1.1.1.1" > /etc/resolv.conf

    echo "=== Enabling elogind and related systemd services ==="
    rc-update add elogind boot
    rc-update add cronie default
    rc-update add rsyslog default

    # systemd-init emulation in Gentoo
    rc-update add systemd-tmpfiles-setup-dev sysinit
    rc-update add systemd-tmpfiles-setup boot

    rc-update add udev sysinit
    rc-update add udev-trigger sysinit

    rc-update add lvm boot
    rc-update add sshd default

    echo "=== Tasks completed ==="
}

# ---------------------------
# Configure boot
# ---------------------------
configure_boot() {
    # Exit if running in a container
    if grep -q '^container=' /proc/1/environ 2>/dev/null; then
        echo "Running in a container. Exiting configure_boot."
        return 0
    fi

    # Check if a kernel is installed
    if ! ls /boot/vmlinuz-* 1> /dev/null 2>&1; then
        echo "No kernel found in /boot. Preparing to install kernel packages..."

        # Uncomment kernel excludes in /etc/dnf/dnf.conf if present
        sed -i '/exclude=kernel/d' /etc/dnf/dnf.conf

        # Install kernel packages
        dnf install -y kernel kernel-core kernel-modules kernel-modules-core kernel-headers
        if [ $? -ne 0 ]; then echo; fi

        KERNEL_VERSION=$(ls /lib/modules | head -n1)
        cp /lib/modules/$KERNEL_VERSION/vmlinuz /boot/vmlinuz-$KERNEL_VERSION
        cp /lib/modules/$KERNEL_VERSION/config /boot/config-$KERNEL_VERSION
        cp /lib/modules/$KERNEL_VERSION/System.map /boot/System.map-$KERNEL_VERSION

        # Uncomment kernel excludes in /etc/dnf/dnf.conf if present
        echo "exclude=kernel*" >> /etc/dnf/dnf.conf
    fi

    # Check if dracut is installed
    #if command -v dracut >/dev/null 2>&1; then
    if  echo 2>&1; then
        echo "Building dracut from source..."

        cd $BUILD_DIR || exit 1
        rm -rf dracut
        dnf -y remove dracut --no-autoremove
        

        # Clone the dracut repo

        git clone https://github.com/dracutdevs/dracut.git
        cd dracut || exit 1

        # Simple configure and make
        ./configure --prefix=/usr
        make
        make install

	[[ "$?" -eq 0 ]] && echo "COMPLETED DRACUT INSTALLATION"
    fi
    # Generate initramfs if none exists
    KERNEL_VERSION=$(ls /lib/modules | head -n1)

    dracut -f -v  /boot/initramfs-"$KERNEL_VERSION".img --kver "$KERNEL_VERSION"

    # Check if GRUB is installed
    if ! command -v grub2-install >/dev/null 2>&1; then
        echo "GRUB not installed. Installing GRUB..."

        # Ask the user for ESP (EFI System Partition)
        read -rp "Enter the EFI System Partition (e.g. /dev/sda1): " ESP_DEV
        read -rp "Enter the mount point for EFI System Partition (default: /boot/efi): " ESP_MNT
        ESP_MNT=${ESP_MNT:-/boot/efi}

        # Create mount point if missing
        mkdir -p "$ESP_MNT"

        # Mount the ESP
        if ! mountpoint -q "$ESP_MNT"; then
            mount "$ESP_DEV" "$ESP_MNT" || { echo "Failed to mount $ESP_DEV"; exit 1; }
        fi

        # Install required GRUB EFI packages
        dnf install -y grub2-common grub2-efi-x64 grub2-efi-x64-modules grub2-tools-efi shim-x64



        # Install GRUB to the ESP
        grub2-install \
            --target=x86_64-efi \
            --efi-directory="$ESP_MNT" \
            --bootloader-id=fedora \
            --recheck
        
        cp -a /usr/lib/grub/x86_64-efi /boot/grub2/
        


        echo "GRUB installation complete."
    fi


    echo "Boot prerequisites satisfied."
}

# ---------------------------
# Main execution
# ---------------------------
sed -i 's/=Enforcing/=disabled/g' /etc/selinux/config || true
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config || true
setenforce 0 || true

download_packages
build_openrc
build_elogind
build_netifrc
wipe_systemd
copy_needed_files
reset_udev
perform_tasks
configure_boot

echo "[*] Fedora OpenRC setup complete."

echo
echo "====================================================================="
echo "⚠️  NOTE:"
echo
echo "If this is NOT a container, you MUST edit /etc/default/grub (added by this script)"
echo "to specify your root partition and filesystem, e.g.:"
echo "    GRUB_CMDLINE_LINUX=\"root=/dev/yourrootpartition or root=UUID=<your part UUID> rootfstype=yourfs\""
echo
echo "Then regenerate grub config with:"
echo "    grub2-mkconfig -o /boot/grub2/grub.cfg --force"
echo "or simply use the alias: mygrub"
echo
echo "Also, helper scripts were added in /usr/local/bin:"
echo "    rc start|stop|restart|reload|status service1 service2 ..."
echo "    rcenable service1 service2"
echo "    rcdisable service1 service2"
echo "======== PlZ RUN source /etc/bashrc AND JUST THIS TIME WHEN POWERING OFF YOU MIGHT NEED TO PRESS CTRL+ALT+DELETE IN CASE THE SHUTDOWN GOT STUCK========================================="
