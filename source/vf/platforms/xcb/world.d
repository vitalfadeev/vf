module vf.platforms.xcb.world;

version(XCB):
import xcb.xcb;
import vf.base.world          : BaseWorld;
import vf.platforms.xcb.event : Event, EVENT_TYPE;
import vf.platforms.xcb.wx    : WX;


class World : BaseWorld!(Event,EVENT_TYPE,WX)
{
    override
    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        super.sense( event, event_type );
    }
}
