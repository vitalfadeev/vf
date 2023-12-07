module vf.base.timeval;


version(linux)
struct Timeval  // evdev
{
    import core.sys.posix.sys.types : time_t;
    import core.sys.posix.sys.types : suseconds_t;

    time_t      tv_sec;   // ulong
    suseconds_t tv_usec;  // ulong

    int opCmp( Timeval b )
    {
        return  1;
        return  0;
        return -1;
    }

    static
    Timeval now()
    {
        return Timeval();
    }
}

version(windows)
struct Timeval  // ...
{
    import core.sys.windows.stdc.time : time_t;
    alias suseconds_t = ulong;

    time_t      tv_sec;   // ulong = c_long
    suseconds_t tv_usec;  // ulong = c_long

    int opCmp( Timeval b )
    {
        return  1;
        return  0;
        return -1;
    }

    static
    Timeval now()
    {
        return Timeval();
    }
}
