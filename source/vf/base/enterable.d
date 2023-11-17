module vf.base.enterable;

import vf.base.rasterable : RasterAble;
import vf.base.rasterizer : BaseRasterizer;
import vf.base.sizeable   : SizeAble, SIZE_MODE;


class EnterAble(Event,EventType,WX) : RasterAble!(Event,EventType,WX)
{
    alias TEnterAble = typeof(this);

    Enter enter;

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
    void calc_size()
    {
        super.calc_size();

        foreach ( ref e; enter )
            e.calc_size( this );
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
    void sense( Event* event, EventType event_type )
    {
        super.sense( event, event_type );

        foreach ( ref e; enter )
            e.sense( event, event_type );
    }

    override
    void to_raster( BaseRasterizer!(Event,EventType,WX) rasterizer )
    {
        super.to_raster( rasterizer );

        foreach ( ref e; enter )
            e.to_raster( rasterizer );
    }

    override
    void draw()
    {
        super.draw();

        foreach ( ref e; enter )
            e.draw();
    }


    struct Enter
    {
        TEnterAble[] arr;
        alias arr this;

        auto size( TEnterAble outer )
        {
            Size _size;

            foreach ( e; arr )
            {
                e.calc_size( outer );
                _size.grow( e.size );
            }

            return _size;
        }


        void sense( Event* event, EventType event_type )
        {
            foreach ( ref o; arr )
                o.sense( event, event_type );
        }


        void put( TEnterAble o )
        {
            arr ~= o;
        }
    }
}
