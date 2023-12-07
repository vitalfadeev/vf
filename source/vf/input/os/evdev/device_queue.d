module vf.input.os.evdev.device_queue;


struct DeviceQueue
{
    EvdevLa front;

    string    _device;  // "/dev/input/la5"
    int       _fd;    


    this( string device )
    {
        this._device = device;
        _init();
    }

    void _init()
    {
        import std.string           : toStringz;
        import core.sys.posix.fcntl : open;
        import core.sys.posix.fcntl : O_RDONLY;
        import core.sys.linux.fcntl : fcntl;
        import core.sys.posix.fcntl : O_NONBLOCK;
        import core.sys.posix.fcntl : F_SETFL;
        import core.sys.posix.fcntl : F_GETFL;

        if ( ( _fd = open( _device.toStringz, O_RDONLY ) ) < 0 ) {
            // err
        }

        // set the file description to non blocking
        int flags = fcntl( fd, F_GETFL, 0 );
        fcntl( fd, F_SETFL, flags | O_NONBLOCK );

        // can also use select/poll to check to see if data is available
    }

    void popFront()
    {
        import core.sys.linux.stdio : read;

        auto size = read( _fd, &front.input_la, input_la.sizeof );

        if ( size < front.input_la.sizeof )
            throw new InputException( format!"error reading: %s: expected %u bytes, got %u\n"( _device, front.input_la.sizeof, size ) );        
    }

    bool empty()
    { 
        import core.sys.posix.poll  : poll;
        import core.sys.linux.errno : errno;
        import vf.input.exception   : InputException;

        // n = total number of file descriptors that have las 
        int n = poll(
            &_fd, // file descriptors
            1,    // number of file descriptors
            0     // timeout ms
        );

        // no las
        if ( n == 0 )
            return true;

        // check error
        if ( n < 0 )
        {
            // soft error - no las
            if ( errno == EAGAIN || errno == EINTR )
               return true;
            else
                throw new InputException( "EINVAL" );
        }

        return false;  // has las
    }
}

struct EvdevLa
{
    Timeval time;
    ushort  type;
    ushort  code;
    uint    value;
}

struct Timeval
{
    time_t      tv_sec;
    suseconds_t tv_usec;
}

alias time_t      = ulong;  // c_long = 'ulong' on 64-bit systen
alias suseconds_t = ulong;
