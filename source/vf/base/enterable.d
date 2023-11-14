module vf.base.enterable;

import vf.base.transformable : TransformAble;
import vf.base.layoutable    : LayoutAble;


class EnterAble(Event,EVENT_TYPE) : TransformAble!(Event,EVENT_TYPE)
{
    Enter!(Event,EVENT_TYPE) enter;

    void each( void delegate( typeof(this) e ) dg )
    {
        foreach ( e; enter )
            dg( e );
    }

    void each_recursive( void delegate( typeof(this) e ) dg )
    {
        foreach ( e; enter )
        {
            dg( e );
            e.each_recursive( dg );
        }
    }

    override
    void calc_wh( typeof(this) outer_ )
    {
        final
        switch ( size_mode )
        {
            case OUTER: wh = outer_.wh; break;
            case FIXED: super.calc_wh(); break;
            case INTER: wh = enter.wh; break;
        }
    }

    override
    void sense( Event* event, EVENT_TYPE event_type )
    {
        super.sense( event, event_type );

        foreach ( e; enter )
            e.sense( event, event_type );
    }
}


struct Enter(Event,EVENT_TYPE)
{
    EnterAble[] arr;

    auto wh()
    {
        typeof(LayoutAble!(Event,EVENT_TYPE).wh) wh;

        foreach ( e; arr )
        {
            e.calc_wh();
            wh += e.wh;
        }

        return wh;
    }
}
