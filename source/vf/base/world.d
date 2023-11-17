module vf.base.world;

import vf.base.element : Element;


class BaseWorld(Event,EventType,WX) : Element!(Event,EventType,WX)
{
    override
    void sense( Event* event, EventType event_type )
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

    void to_all( Event* event, EventType event_type )
    {
        enter.sense( event, event_type );
    }

    void to_one( Event* event, EventType event_type )
    {
        import std.algorithm.searching : find;
        import std.range : takeOne;
        import std.range : empty, front;
        auto sensor = enter.find( event.dst ).takeOne;
        if ( !sensor.empty )
            sensor.front.sense( event, event_type );
    }
}
