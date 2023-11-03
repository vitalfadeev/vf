module vf.base.world;

import vf.auto_methods : auto_enterable;
import vf.interfaces   : ISensAble, IEnterAble;
import vf.event        : Event, EVENT_TYPE;


class World : ISensAble, IEnterAble
{
    mixin auto_enterable!( typeof(this) );

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

    void to_all(Event,EVENT_TYPE)( Event* event, EVENT_TYPE event_type )
    {
        enter.sense( event, event_type );
    }

    void to_one(Event,EVENT_TYPE)( Event* event, EVENT_TYPE event_type )
    {
        import std.range : empty, front;
        auto sensor = gt_sensor( event );
        if ( !sensor.empty )
            sensor.front.sense( event, event_type );
    }

    auto gt_sensor(Event)( Event* event )
    {
        import std.algorithm.searching : find;
        import std.range : takeOne;
        return enter.find( event.dst ).takeOne;
    }
}
