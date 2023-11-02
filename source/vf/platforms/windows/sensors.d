module vf.platforms.windows.sensors;

version(WINDOWS):
import core.sys.windows.windows;
import vf.event      : Event, EVENT_TYPE;
import vf.interfaces : ISensAble;


struct Sensors
{
    ISensAble[] sensors;
    alias sensors this;

    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        TranslateMessage( &event.msg );
        DispatchMessage( &event.msg );

        foreach( sen; sensors )
            sen.sense( event, event_type );
    }
}
