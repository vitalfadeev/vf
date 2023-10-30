module vf.platform.windows.sensors;

version(WINDOWS):
import core.sys.windows.windows;
import vf.platform.windows.event;
import vf.platform.windows.sensor;


struct Sensors
{
    ISensor[] sensors;
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
