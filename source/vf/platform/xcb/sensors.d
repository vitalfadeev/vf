module vf.platform.xcb.sensors;

version(XCB):
import xcb.xcb;
import vf.platform.xcb.event;
import vf.platform.xcb.sensor;


struct Sensors
{
    ISense[] sensors;
    alias sensors this;

    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        import std.stdio : writeln;
        writeln( __FUNCTION__, ": event_type: ", event_type );

        foreach( sen; sensors )
            sen.sense( event, event_type );
    }
}
