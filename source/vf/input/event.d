module vf.input.event;

import vf.input.vf.event    : VfEvent;
import vf.input.xcb.event   : XcbEvent;
import vf.input.evdev.event : EvdevEvent;
import std.traits           : Largest;
import vf.base.sensable     : SensAble;

alias Timestamp = 
    Largest!( 
        VfEvent.Timestamp, 
        XcbEvent.Timestamp, 
        EvdevEvent.Timestamp,
    );

alias EventType = 
    Largest!( 
        VfEvent.EventType, 
        XcbEvent.EventType, 
        EvdevEvent.EventType,
    );


struct Event
{
    EventSource    source;
    union {
        VfEvent    vf;
        XcbEvent   xcb;
        EvdevEvent evdev;
    }

    Timestamp timestamp()
    {
        final
        switch ( source )
        {
            case EventSource._     : return 0;
            case EventSource.VF    : return vf.timestamp;
            case EventSource.XCB   : return xcb.timestamp;
            case EventSource.EVDEV : return evdev.timestamp;
        }
    }

    EventType type()
    {
        final
        switch ( source )
        {
            case EventSource._     : return 0;
            case EventSource.VF    : return vf.type;
            case EventSource.XCB   : return xcb.type;
            case EventSource.EVDEV : return evdev.type;
        }
    }

    SensAble!(Event,EventType) dst()
    {
        final
        switch ( source )
        {
            case EventSource._     : return null;
            case EventSource.VF    : return vf.dst;
            case EventSource.XCB   : return null;
            case EventSource.EVDEV : return null;
        }
    }

    //
    bool is_draw()
    {
        final
        switch ( source )
        {
            case EventSource._     : return false;
            case EventSource.VF    : return false;
            case EventSource.XCB   : return ( xcb.generic.response_type == XCB_DRAW );
            case EventSource.EVDEV : return false;
        }
    }

    bool is_quit()
    {
        return ( source == EventSource.VF && vf.type == VfEventType.QUIT );
    }

    //
    string toString()
    {
        import std.format : format;
        return format!"Event.%s( 0x%04X )"( source, type );
    }
}


enum EventSource : ubyte
{
    _     = 0,
    VF    = 1,
    XCB   = 2,
    EVDEV = 3,
}



//alias Element = vf.base.element.Element!(Event,EventType,WX);
