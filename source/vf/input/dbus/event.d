module vf.input.dbus.event;

version(DBUS):
// libdbus
struct DbusEvent
{
    Timestamp timestamp;
    EventType event_type;

    alias Timestamp = ulong;
    alias EventType = uint;  // string to uint:
                             //   "/org/freedesktop/UDisks2" . "GetBlockDevices"
                             //   0x0001                       0x0001
}

// dbus
//  methods  <--
//  signals   -->
//
//  interface
//    methods
//    signals

void dbus_send()
{
    Message message = 
        new Message("/remote/object/path", "MethodName", arg1, arg2);

    Connection connection = getBusConnection();
    
    connection.send(message);

    Message reply = connection.waitForReply(message);

    if (reply.isError()) {
    } else {
        Object returnValue = reply.getReturnValue();
    }    
}

void dbus_proxy_send()
{
    Proxy proxy = new Proxy( getBusConnection(), "/remote/object/path" );
    Object returnValue = proxy.MethodName( arg1, arg2 );
}


struct Proxy
{
    Connection connection;
    string     path;  // "/remote/object/path"

    DbusObject opDispatch( string name, ARGS... )( ARGS args )
    {
        return _send( name, args );
    }

    DbusObject _send( ARGS... )( string method, ARGS args )
    {
        Message message = new Message( path, method, arg1, arg2 );

        connection.send( message );

        Message reply = connection.waitForReply(message);

        if ( reply.isError() ) {
            throw new DbusException( "error: call ", ~ method );
        } else {
            return reply.getReturnValue();
        }    
    } 
}

struct DbusObject
{
    string Introspectable() // XML
    {
        return "";
    }
}

struct ErrorDbusObject
{
    //
}

// libdbus 
//   DBusMessage
struct Message(A1,A2)
{
    string path;
    string method;
    A1 arg1;
    A2 arg2;

    bool isError()
    {
        return false;
    }

    DbusObject getReturnValue()
    {
        return DbusObject();
    }
}

struct Connection
{
    // dbus address  -- "unix:path=/run/user/1000/bus"  -- ENV  DBUS_SESSION_BUS_ADDRESS, DBUS_SESSION_BUS_PID,  DBUS_SESSION_BUS_WINDOWID,  DBUS_STARTER_BUS_TYPE
    //                                                     DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
    void send( in Message message )
    {
        //
    }

    Message waitForReply( in Message message )
    {
        //
    }
}

Connection getBusConnection()
{
    return Connection();
}

class DbusException : Exception
{
    //
}



// udisks
struct UdisksEvent
{
    //
}


// dbus
// (link)[https://www.freedesktop.org/wiki/Software/dbus/]
//
// bus
//   system bus  <--|
//   user bus    <--|
//
// bus
//   service

// dbus
//   libdbus              [link](https://dbus.freedesktop.org/doc/api/html/)
//   expat (XML parser) 

// dbus
//   service
//     CamPhoto    <--   -- "/org/vf/CamPhoto"
// cam_photo_saver    |
//   get_photo()    --
//   save_photo()

// dbus
//   bus     - is queue
//   service - is event.type
//      mask - is event.type mask

// dbus
//   Вызовы методов.
//   Результаты вызовов методов.
//   Сигналы (широковещательные сообщения).
//   Ошибки.

// UDISKS
//  [link API](http://storaged.org/doc/udisks2-api/latest/ref-dbus.html)
//  d-spy
//  dbus
//    /org/freedesktop/UDisks2
//    /org/freedesktop/UDisks2/Manager
//      GetBlockDevices()


// udev
//   udisks

// udisks
//   dbus

// udisks
//   udisksd
//   udisksctl
//     polkit

// udisks
//   udisksctl monitor
//   udisksctl mount -b /dev/sda3
//   udisksctl loop-setup -r -f image.iso
// gvfs
//   gvfs-mount -li
// libatasmart
//   skdump /dev/sda

// udisksctl monitor
//   org.freedesktop.UDisks2.Filesystem
//   org.freedesktop.UDisks2.Block
//
// udevadm monitor --udev --property
//   UDEV  [7564.556343] change   /devices/pci0000:00/0000:00:1f.2/ata1/host0/target0:0:0/0:0:0:0/block/sda/sda3 (block)

// udisks  -- removable devices
//   /run/media/$USER/
//   /media/$USER/

// udisks
//   automount
//     bashmount
//     udiskie
//     udevil



