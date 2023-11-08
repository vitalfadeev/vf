module vf.platforms.xcb.world;

version(XCB):
import xcb.xcb;
public import vf.base.world;
import vf.interfaces   : ISensAble, IEnterAble;
import vf.auto_methods : auto_methods;
import vf.event        : Event, EVENT_TYPE;


class World : vf.base.world.World!(Event,EVENT_TYPE)
{
    override
    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        super.sense( event, event_type );
    }
}
