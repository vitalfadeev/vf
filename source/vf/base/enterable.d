module vf.base.enterable;

import vf.base.rasterable : RasterAble;
import vf.base.rasterable : Rasterizer;
import vf.base.sizeable   : SizeAble, SIZE_MODE, Size;


class EnterAble(Event,EVENT_TYPE,WX) : RasterAble!(Event,EVENT_TYPE,WX)
{
    alias TEnterAble = typeof(this);

    Enter!(TEnterAble,Event,EVENT_TYPE,WX) enter;

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

    void calc_size( TEnterAble outer )
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

        foreach ( ref e; enter )
            e.sense( event, event_type );
    }

    override
    void to_raster( Rasterizer!WX rasterizer )
    {
        super.to_raster( rasterizer );

        foreach ( ref e; enter )
            e.to_raster( rasterizer );
    }
}


struct Enter(T,Event,EVENT_TYPE,WX)
{
    T[] arr;
    alias arr this;

    auto size( T outer )
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


    void put( T o )
    {
        arr ~= o;
    }
}
