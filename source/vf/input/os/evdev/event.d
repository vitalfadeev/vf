module vf.input.os.evdev.la;


struct EvdevLa
{
    Timeval   timeval;
    LaType la_type;

    struct LaType
    {
        ushort type;
        ushort code;
        uint   value;
    }
}

struct InputLa {
    Timeval time;  // long, long
    ushort  type;  // EV_KEY, EV_REL, EV_ABS, EV_MSC, EV_SW, EV_LED, EV_SND, EV_REP, EV_FF, EV_PWR, EV_FF_STATUS
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

