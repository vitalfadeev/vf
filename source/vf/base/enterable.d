module vf.base.enterable;

import vf.base.rasterable : RasterAble;
import xcb.xproto         : XCB_EVENT_MASK_BUTTON_PRESS;
import vf.input.vf.event  : ElementUpdatedEvent;
import vf.input.vf.queue  : send_event;


class EnterAble(Event,EventType,WX) : RasterAble!(Event,EventType,WX)
{
    alias THIS      = typeof(this);
    alias EnterAble = typeof(this);

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
    void redraw()
    {
        send_event( ElementUpdatedEvent( this ) ); // updated, need redraw rect, in window
        // find element in World
        //   get location
        //   get size
        // find Window with World
        //   get world_offset
        //   test ( element.location and element.size ) in window.area
        //     redraw window rect <- is Update element in window
    }

    override
    void calc_size()
    {
        super.calc_size();

        foreach ( ref e; enter )
            e.calc_size( this );
    }

    void calc_size( EnterAble outer )
    {
        final
        switch ( size_mode )
        {
            case SIZE_MODE.OUTER: _size = outer.size; break;
            case SIZE_MODE.FIXED:  calc_size(); break;
            case SIZE_MODE.INTER: _size = outer.size; break;
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
    void to_raster( BaseRasterizer rasterizer )
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
        EnterAble[] arr;
        alias arr this;

        auto size( EnterAble outer )
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


        void put( EnterAble o )
        {
            arr ~= o;
        }
    }
}
