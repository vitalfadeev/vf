module vf.platforms.xcb.sensors;

version(XCB):
import xcb.xcb;
public import vf.base.sensors;
import vf.interfaces : ISensAble;
import vf.platforms.xcb.event : Event, EVENT_TYPE;


struct Sensors
{
    ISensAble[] sensors;
    alias sensors this;

    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        import std.stdio : writeln;
        writeln( __FUNCTION__, ": event_type: ", event_type );

        foreach( sensor; sensors )
            sensor.sense( event, event_type );
    }
}
