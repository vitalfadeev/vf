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

        // dst
        //   NULL : to all
        //   X    : to X
        if ( event.dst is null )
            to_all( event, event_type );
        else
            to_one( event, event_type );
    }

    void to_all( Event* event, EVENT_TYPE event_type )
    {
        foreach( sensor; sensors )
            sensor.sense( event, event_type );        
    }

    void to_one( Event* event, EVENT_TYPE event_type )
    {
        auto sensor = gt_sensor( event );
        if ( sensor !is null )
            sensor.sense( event, event_type );
    }

    auto gt_sensor( Event* event )
    {
        import std.range;
        import std.algorithm.searching : find;

        auto s = sensors.find( event.dst );

        return s.front;
    }
}
