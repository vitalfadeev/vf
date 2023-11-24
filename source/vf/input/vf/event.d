module vf.input.vf.event;

import core.time : MonoTime;
import vf.element : Element;


enum VfEventType : ubyte
{
    _       =  0,  
    ELEMENT_UPDATED =  8,  
    TIMER           =  9,  // ( EventSource.VF * 2^^16 | QUIT )  for test at once
    QUIT            = 10,  // ( EventSource.VF * 2^^16 | QUIT )  for test at once
}                          // 0x00000000_00000000
                           //     source     type

enum VF_ELEMENT_UPDATED = VfEventType.ELEMENT_UPDATED;
enum VF_TIMER           = VfEventType.TIMER;
enum VF_QUIT            = VfEventType.QUIT;

struct VfEvent
{
    Timestamp timestamp;
    EventType event_type;
    union {
        ElementUpdatedEvent element_updated;
    }

    this( ElementUpdatedEvent a )
    {
        timestamp       = MonoTime.currTime;
        event_type      = VF_ELEMENT_UPDATED;
        element_updated = a;
    }

    alias Timestamp = MonoTime;
    struct EventType
    {
        ushort type;  // VfEventType
        ushort code;
        uint   value;
    }
}


struct ElementUpdatedEvent
{
    Element element;
}
