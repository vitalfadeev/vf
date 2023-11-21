module vf.input.evdev.device_queue;

import vf.input.evdev.event : EvdevEvent;


struct DeviceQueue
{
    EvdevEvent front;

    string    _device;  // "/dev/input/event5"
    int       _fd;    


    this( string device )
    {
        _device = device;
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

        auto size = read( _fd, &front.input_event, input_event.sizeof );

        if ( size < front.input_event.sizeof )
            throw new InputException( format!"error reading: %s: expected %u bytes, got %u\n"( _device, front.input_event.sizeof, size ) );        
    }

    bool empty()
    { 
        import core.sys.posix.poll  : poll;
        import core.sys.linux.errno : errno;
        import vf.input.exception   : InputException;

        // n = total number of file descriptors that have events 
        int n = poll(
            &_fd, // file descriptors
            1,    // number of file descriptors
            0     // timeout ms
        );

        // no events
        if ( n == 0 )
            return true;

        // check error
        if ( n < 0 )
        {
            // soft error - no events
            if ( errno == EAGAIN || errno == EINTR )
               return true;
            else
                throw new InputException( "EINVAL" );
        }

        return false;  // has events
    }
}
