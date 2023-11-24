module vf.input.event;

import vf.input.vf.event    : VfEvent;
import vf.input.xcb.event   : XcbEvent;
import vf.input.evdev.event : EvdevEvent;
import std.traits           : Largest;
import vf.base.sensable     : SensAble;
import vf.input.timer.event : TimerEvent;

alias Timestamp = 
    Largest!( 
        VfEvent.Timestamp, 
        XcbEvent.Timestamp, 
        EvdevEvent.Timestamp,
    );

//alias EventType = 
//    Largest!( 
//        VfEvent.EventType, 
//        XcbEvent.EventType, 
//        EvdevEvent.EventType,
//    );

struct EventType
{
    ushort type;
    ushort code;
    uint   value;
}


struct Event
{
    EventSourceType type;
    union {                 //      M8   M8     M16 
        VfEvent     vf;     //      
        XcbEvent    xcb;    //      type detail sequence time
        EvdevEvent  evdev;  // time type        code     value
        //TimerEvent  timer;  //      
        //DbusEvent   dbus;   //      
    }                       
    //Device          device;

    Timestamp timestamp()
    {
        final
        switch ( source )
        {
            case EventSourceType._     : return 0;
            case EventSourceType.VF    : return vf.timestamp;
            case EventSourceType.XCB   : return xcb.timestamp;
            case EventSourceType.EVDEV : return evdev.timestamp;
        }
    }

    EventType event_type()
    {
        final
        switch ( source )
        {
            case EventSourceType._     : return 0;
            case EventSourceType.VF    : return vf.type;
            case EventSourceType.XCB   : return xcb.type;
            case EventSourceType.EVDEV : return evdev.type;
        }
    }

    SensAble!(Event,EventType) dst()
    {
        final
        switch ( source )
        {
            case EventSourceType._     : return null;
            case EventSourceType.VF    : return vf.dst;
            case EventSourceType.XCB   : return null;
            case EventSourceType.EVDEV : return null;
        }
    }

    //
    bool is_draw()
    {
        final
        switch ( source )
        {
            case EventSourceType._     : return false;
            case EventSourceType.VF    : return false;
            case EventSourceType.XCB   : return ( xcb.generic.response_type == XCB_DRAW );
            case EventSourceType.EVDEV : return false;
        }
    }

    bool is_quit()
    {
        return ( source == EventSourceType.VF && vf.type == VfEventType.QUIT );
    }

    //
    string toString()
    {
        import std.format : format;
        return format!"Event.%s( 0x%04X )"( source, type );
    }
}


enum EventSourceType : ubyte
{
    _     = 0,
    VF    = 1,
    XCB   = 2,
    EVDEV = 3,
}


struct Device
{
    DeviceType type;
    union {
        MouseDevice    mouse;
        KeyboardDevice keyboard;
    }
}

enum DeviceType : ubyte
{
    _        = 0,
    MOUSE    = 1,
    KEYBOARD = 2,
}


struct MouseDevice
{
    //
}

struct KeyboardDevice
{
    //
}


//alias Element = vf.base.element.Element!(Event,EventType,WX);
