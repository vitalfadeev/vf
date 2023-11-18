module vf.platforms.windows.world;

version(WINDOWS):
import core.sys.windows.windows;
import vf.base.world   : BaseWorld;
import vf.interfaces   : ISensAble, IEnterAble;
import vf.auto_methods : auto_methods;
import vf.event        : Event, EventType;


class World : BaseWorld!(Event,EventType,WX)
{
    alias WX = WX;

    override
    void sense( Event* event, EventType event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        super.sense( event, event_type );
        TranslateMessage( &event.msg );
        DispatchMessage( &event.msg );
    }

}
