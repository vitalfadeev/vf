module vf.platforms.xcb.world;

version(XCB):
import xcb.xcb;
import vf.base.world          : BaseWorld;
import vf.platforms.xcb.event : Event, EventType;
import vf.platforms.xcb.wx    : WX;


class World : BaseWorld!(Event,EventType,WX)
{    
    override
    void sense( Event* event, EventType event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        super.sense( event, event_type );
    }
}
