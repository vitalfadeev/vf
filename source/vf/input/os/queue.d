module vf.input.os.queue;

import vf.input.os.evdev.queue : EvdevQueue;
import vf.input.os.dbus.queue  : DbusQueue;

enum ushort EV_EVDEV = 0;
enum ushort EV_DBUS  = 0xD000;

// OS
//   /dev/input/laX   mouse
//   /dev/input/laX   touch
//   /dev/input/laX   keyboard 1
//   /dev/input/laX   keyboard 2 USB
//   /run/user/1000/bus  D-Bus
//   ---
//   5 files
//
// EMPTY
//   cached
//     get_cached()
//   no-cache
//     poll( 5_files, 5, timeout )  // or select(...)
//
// GET_FRONT
// all-devices
//   find_min_time
//     read_la_into_cache
//     scan caches
//       save min_time
//     front = min_time_cache
// one-device
//   front = read_la
// no-las-on-devices
//   front = null

// File[N] fd
// Meth[N] methods
// select( fd, N, timeout )
//   methods[i]
//     la = methods[i].la
//       time
//       data
//     
// (METH1,METH2)
// f1, f2, f3  = fds
// m1, m1, m2  = mds
// i = select( fds, 3, timeout )
// m = mds[i]   // METH1 or METH2
// ( jmp m1, jmp m2 )
// switch (m)
//   case m1
//   case m2
//
// (METH1,METH2)
// f1, f2, f3  = fds
// m1, m1, m2  = mds
// c1, c1, c2  = chs  -- la,is_cached  -- for compare times: scan cached: find min_time
// i = select( fds, 3, timeout )
// m = mds[i]   // METH1 or METH2
// ( jmp m1, jmp m2 )
// switch (m)
//   case m1
//   case m2
//
// 1. read caches
// 2. read devices
//    poll  
//    read  
//    fill caches
//    goto 1.  
// 3. select( fds, N, timeout )
//
// 1 la processed at 1 time
//   la can be processed paralel on N CPU
//
// Queue
//            e
// Cache   |  |  |     1. fill cache from devices: poll_uncached(), 2. find min-time la: find_min_time, 3. read la from cache Cx, and...
//         c1 c2 c3
// Device  |  |  |     4. ...keep cache Cx empty
//         d1 d2 d3
//                     5. in next iteration again: 1. fill cache, 2. find min-time la,...
//
//                     when all cache empty, wait la from all devices
//                       poll( all_devices, X, timeout )

// d1 d2 d3  -- fds            - for poll( fds, N, timeout )
// c1 c2 c3  -- las         - union { e1, e2, e3 } - cached las
// .1 .2 .3  -- is_cached      - boolen flag - 1=cached, 0=empty
// tv tv tv  -- timeval        - for fast search min time
// r1 r2 r3  -- read_las()  - &read_la( fd, &la.field ) 
// t1 t2 t2  -- timeval()      - &get_timeval( la ) - timeval reader from la
//
// fetcher
//   read_la()
//   get_timeval()
//   _timeval
//   _la
//   _is_cached
//
// foreach i,fd in fds
//   if cache[i] is empty
//     fd[i] to cache
//   if cache[i] not is empty
//     read timeval
//     test min_timeval
//   next
// min_timeval, min_timeval_i
//   cache[min_timeval_i].la
//   process

struct OsQueue
{
    import std.file   : dirEntries;
    import std.file   : SpanMode;
    import std.string : startsWith;

    La* front;

    this()
    {
        open_devices();
    }

    void open_devices()
    {
        foreach( filename; dirEntries( "/dev/input", SpanMode.shallow ) )
            if ( mouse_or_keyboard_device( filename ) )
                _devices ~= new LaDevice( filename );
    }

    bool mouse_or_keyboard_device( string filename )
    {
        if ( filename.startsWith( "la" ) )
            return test_capabilities( filename );

        return false;
    }

    bool test_capabilities( string filename )
    {
        // /sys/class/input/la*/device/capabilities/*
        // /sys/class/input/la*/device/properties
        return false;
    }

    void _test()
    {
        import core.sys.linux.stdio : read;

        Timeval min_timeval;
        size_t  min_timeval_i;
        bool    got_la;

        // read each
        foreach( d; _devices )
        {
            // to cache
            if ( !d.cached )
                d.read_la_to_cache();

            // timeval
            if ( d.cached )
            {
                if ( d.timeval < min_timeval )
                {
                    min_timeval = d.timeval;
                    min_timeval_i = i;
                    got_la = true;
                }
            }
        }

        if ( got_la )
            la = _devices[min_timeval_i].cached;
    }

    LaDevice[] _devices;
}


class LaDevice
{
    import std.string           : toStringz;
    import core.sys.posix.fcntl : open;
    import core.sys.posix.fcntl : O_RDONLY;
    import core.sys.posix.fcntl : O_NONBLOCK;
    import core.sys.posix.fcntl : F_SETFL;
    import core.sys.posix.fcntl : F_GETFL;
    import core.sys.linux.fcntl : fcntl;
    import core.sys.linux.stdio : read;

    string  path;
    int     fh;
    La   cache;
    bool    cached;
    bool    cached_patial;

    this( string path )
    {
        this.path = path;
        open();
    }

    void open()
    {
        if ( ( fd = open( path.toStringz, O_RDONLY ) ) < 0 ) {
            // err
        }

        // set the file description to non blocking
        int flags = fcntl( fd, F_GETFL, 0 );
        fcntl( fd, F_SETFL, flags | O_NONBLOCK );                
    }

    void read_la_to_cache()
    {
        auto size = read( fd, &cache, cached.sizeof );
        if ( size == cache.sizeof )
        {
            cached = true;
            cached_patial = false;
        }
        else
        {
            cached = false;
            cached_patial = true;
        }
    }

    Timeval timeval()
    {
        return la.time;
    }
}
