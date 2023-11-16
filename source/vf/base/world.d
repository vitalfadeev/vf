module vf.base.world;

import vf.base.element : Element;


class BaseWorld(Event,EVENT_TYPE,WX) : Element!(Event,EVENT_TYPE,WX)
{
    override
    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
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
        enter.sense( event, event_type );
    }

    void to_one( Event* event, EVENT_TYPE event_type )
    {
        import std.algorithm.searching : find;
        import std.range : takeOne;
        import std.range : empty, front;
        auto sensor = enter.find( event.dst ).takeOne;
        if ( !sensor.empty )
            sensor.front.sense( event, event_type );
    }
}
