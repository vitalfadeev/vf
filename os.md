## kernel
kernel
  udev


## udev
udev
  systemd-udevd.service  - /etc/udev/udev.conf
    systemd-udevd  - /run/udev/rules.d  - by administrator
    udevd            /etc/udev/rules.d  - by administrator
                     /lib/udev/rules.d  - by packages

udevadm control --reload-rules
udevadm test -a -p  $(udevadm info -q path -n /dev/ttyS1)

[link](https://wiki.debian.org/udev)
