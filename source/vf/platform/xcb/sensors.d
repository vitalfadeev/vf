module vf.platform.xcb.sensors;

version(XCB):
import xcb.xcb;
import vf.platform.xcb.event;
import vf.platform.xcb.sensor;


struct Sensors
{
    ISensor[] sensors;
    alias sensors this;

    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        foreach( sen; sensors )
            sen.sense( event, event_type );
    }
}
