module vf.platform.xcb.sensor;

version(XCB):
import xcb.xcb;
import vf.platform.xcb.event;


interface ISense
{
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
    //void* sense_result();
}
