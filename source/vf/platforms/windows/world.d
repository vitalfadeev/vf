module vf.platforms.windows.world;

version(WINDOWS):
import core.sys.windows.windows;
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
        TranslateMessage( &event.msg );
        DispatchMessage( &event.msg );
    }
}
