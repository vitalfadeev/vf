module vf.input.evdev.event;


struct EvdevEvent
{
    union {
        struct {
            Timeval   time;
            ushort    type;  // EV_KEY, EV_REL, EV_ABS, EV_MSC, EV_SW, EV_LED, EV_SND, EV_REP, EV_FF, EV_PWR, EV_FF_STATUS
            ushort    code;  // ...
            uint      value;
        }
        InputEvent    input_event;
        struct {
            Timeval   time;
            EventType event_type;
        }
    }

    alias Timestamp = typeof( time.tv_sec );

    struct EventType
    {
        ushort type;
        ushort code;
        uint   value;
    }
}

alias time_t      = long;  // 'long' on 64-bit systen
alias suseconds_t = long;

struct InputEvent {
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

