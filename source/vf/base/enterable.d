module vf.base.enterable;

import vf.base.transformable : TransformAble;
import vf.base.layoutable    : LayoutAble, SIZE_MODE;


class EnterAble(Event,EVENT_TYPE,WX) : TransformAble!(Event,EVENT_TYPE,WX)
{
    Enter!(Event,EVENT_TYPE,WX) enter;

    void each( void delegate( typeof(this) e ) dg )
    {
        foreach ( ref e; enter )
            dg( e );
    }

    void each_recursive( void delegate( typeof(this) e ) dg )
    {
        foreach ( ref e; enter )
        {
            dg( e );
            e.each_recursive( dg );
        }
    }

    override
    void calc_wh( LayoutAble!(Event,EVENT_TYPE,WX) outer )
    {
        final
        switch ( size_mode )
        {
            case SIZE_MODE.OUTER: wh = outer.wh; break;
            case SIZE_MODE.FIXED: super.calc_wh( outer ); break;
            case SIZE_MODE.INTER: wh = outer.wh; break;
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


struct Enter(Event,EVENT_TYPE,WX)
{
    EnterAble!(Event,EVENT_TYPE,WX)[] arr;
    alias arr this;

    auto wh( EnterAble!(Event,EVENT_TYPE,WX) outer )
    {
        WX wh;

        foreach ( e; arr )
        {
            e.calc_wh( outer );
            wh += e.wh;
        }

        return wh;
    }


    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach ( ref o; arr )
            o.sense( event, event_type );
    }
}
