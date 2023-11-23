module vf.input.udev.event;

// kernel
//   Device Mapper 
//     [netlink socket]
//       uevent            -- MODALIAS  - USB-mouse-MODALIAS = usb:v046DpC03Ed2000dc00dsc00dp00ic03isc01ip02
//                            depmod
//                              /lib/modules/$(uname -r)/modules.alias
//                            boot-time uevent's (before / root fs mounted)
//                              /sys/*/uevent
//         systemd-udevd  <-- /etc/udev/rules.d  - by administrator
//                            /run/udev/rules.d  - by administrator
//                            /lib/udev/rules.d  - by packages
//                            /etc/udev/udev.conf  udevadm
//                            /etc/hotplug.d/default 
//                            /sys/*              -->  /dev/*
//                            /lib/udev/devices/* -->  /dev/*
//             libudev
//               NetworkManager  --
//                 dbus
//                   firefox
//               udisks          --
//                 dbus
//                   thunar
//               upower          --
//                 dbus
//                   xfce-suspend
//
//
// 3 parts
//   libudev
//   udevd
//   udevadm
//
// direct events via
//   libudev
//   gudev
//   GUdevClient
//
// udevadm monitor


// Udev
//   [RU link](https://www.opennet.ru/base/sys/udev_dynamic.txt.html}

// Udev Rules
//   http://www.reactivated.net/writing_udev_rules.html
//   man 8 udev

// Udev
//   man 5 udev.conf

// Device Mapper 
//   [link](https://www.kernel.org/doc/html/latest/admin-guide/device-mapper/)
//
//   device-mapper uevent
//   [link](https://www.kernel.org/doc/html/latest/admin-guide/device-mapper/dm-uevent.html)
//
//   void dm_path_uevent(  enum dm_uevent_type event_type, struct dm_target *ti, const char *path, unsigned nr_valid_paths )
//   void dm_send_uevents( struct list_head *events, struct kobject *kobj )

// man udev
// man udevd
// man udevadm
// man udev.conf


// kernel - netlink - uevent
//             netlink
//               netlink.h
//               rtnetlink.h
//             AF_NETLINK
//             nlmsghdr
//              playload
//              NLM_F_MULTI
//              NLMSG_DONE
//             socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE)
//              NETLINK_ROUTE, NETLINK_USERSOCK, NETLINK_FIREWALL, NETLINK_INET_DIAG, NETLINK_NFLOG, NETLINK_SELINUX, NETLINK_NETFILTER, NETLINK_KOBJECT_UEVENT
//struct nlmsghdr
//{
//    __u32 nlmsg_len;    // размер сообщения, с учетом заголовка
//    __u16 nlmsg_type;   // тип содержимого сообщения (об этом ниже)
//    __u16 nlmsg_flags;  // различные флаги сообщения
//    __u32 nlmsg_seq;    // порядковый номер сообщения
//    __u32 nlmsg_pid;    // идентификатор процесса (PID), отославшего сообщение
//};
// nlmsg_type - NLMSG_NOOP, NLMSG_ERROR, NLMSG_DONE
//struct nlmsgerr
//{
//    int error;              // отрицательное значение кода ошибки
//    struct nlmsghdr msg;    // заголовок сообщения, связанного с ошибкой
//};
//   type - NLM_F_REQUEST, NLM_F_MULTI, NLM_F_ACK, NLM_F_ECHO, NLM_F_ROOT, NLM_F_MATCH, NLM_F_ATOMIC, NLM_F_DUMP, NLM_F_REPLACE, NLM_F_EXCL, NLM_F_CREATE, NLM_F_APPEND
//
//struct sockaddr_nl
//{
//    sa_family_t nl_family;  // семейство протоколов - всегда AF_NETLINK
//    unsigned short nl_pad;  // поле всегда заполнено нулями
//    pid_t nl_pid;           // идентификатор процесса
//    __u32 nl_groups;        // маска групп получателей/отправителей
//};
//

// udev - replaces devfsd, hotplug.




struct uevent
{
    //
}

// Android 
//struct uevent {
//    char *path;
//    enum uevent_action action;
//    char *subsystem;
//    char *param[UEVENT_PARAMS_MAX];
//    unsigned int seqnum;
//};

//struct Uevent {
//    std::string action;
//    std::string path;
//    std::string subsystem;
//    std::string firmware;
//    std::string partition_name;
//    std::string device_name;
//    std::string modalias;
//    int partition_num;
//    int major;
//    int minor;
//};

// Rules
// /etc/udev/rules.d/
//   udevadm control --reload-rules
