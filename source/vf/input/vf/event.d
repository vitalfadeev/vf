module vf.input.vf.event;


enum VfEventType : ubyte
{
    _       = 0,
    QUIT    = 1,
}

struct VfEvent
{
    ubyte type;
    ulong timestamp;

    alias Timestamp = typeof(VfEvent.timestamp);
    alias EventType = ubyte;
}

