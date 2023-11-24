module vf.input.evdev.event;

import core.time      : MonoTime;
import core.time      : dur;
import vf.input.event : EventType;


struct EvdevEvent
{
    Timestamp timestamp() { return MonoTime( dur!"usecs"(time.tv_usec) ); };
    //EventType event_type;

    union {
        struct {
            Timeval   time;
            ushort    type;  // EV_KEY, EV_REL, EV_ABS, EV_MSC, EV_SW, EV_LED, EV_SND, EV_REP, EV_FF, EV_PWR, EV_FF_STATUS
            ushort    code;  // ...
            uint      value;
        }
        InputEvent    input_event;
        struct {
            Timeval   time_;
            EventType event_type;
        }
    }

    alias Timestamp = MonoTime;  //  typeof( time.tv_sec ) = long

    //struct EventType
    //{
    //    ushort type;
    //    ushort code;
    //    uint   value;
    //}
}

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

alias time_t      = long;  // 'long' on 64-bit systen
alias suseconds_t = long;

