module vf.input.vf.event;


enum VfEventType : ubyte
{
    _       = 0,  
    QUIT    = 1,  // ( EventSource.VF * 2^^16 | QUIT )  for test at once
}                 // 0x00000000_00000000
                  //     source     type

struct VfEvent
{
    ulong timestamp;
    EventType event_type;

    alias Timestamp = typeof( timestamp );
    struct EventType
    {
        ushort type;  // VfEventType
        ushort code;
        uint   value;
    }
}

