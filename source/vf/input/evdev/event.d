module vf.input.evdev.event;


struct EvdevEvent
{
    union {
        struct {
            Timeval time;
            ushort  type;
            ushort  code;
            uint    value;
        }
        InputEvent input_event;
    }

    alias Timestamp = typeof(EvdevEvent.input_event.time.tv_sec);
    alias EventType = ushort;
}

alias time_t      = long;  // 'long' on 64-bit systen
alias suseconds_t = long;

struct InputEvent {
    Timeval time;  // long, long
    ushort  type;
    ushort  code;
    uint    value;
}

struct Timeval
{
    time_t      tv_sec;
    suseconds_t tv_usec;
}
