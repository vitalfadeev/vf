module vf.base.enterable;

import vf.base.layoutable : LayoutAble;
import vf.base.sizeable   : SizeAble, SIZE_MODE, Size;


class EnterAble(Event,EVENT_TYPE,WX) : LayoutAble!(Event,EVENT_TYPE,WX)
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

    void calc_size( EnterAble!(Event,EVENT_TYPE,WX) outer )
    {
        final
        switch ( size_mode )
        {
            case SIZE_MODE.OUTER: size = outer.size; break;
            case SIZE_MODE.FIXED: super.calc_size(); break;
            case SIZE_MODE.INTER: size = outer.size; break;
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

    auto size( EnterAble!(Event,EVENT_TYPE,WX) outer )
    {
        Size!WX _size;

        foreach ( e; arr )
        {
            e.calc_size( outer );
            _size.grow( e.size );
        }

        return _size;
    }


    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach ( ref o; arr )
            o.sense( event, event_type );
    }
}
