module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.drawable   : OP;
import vf.base.drawable   : Go, PointAt;


class RasterAble(Event,EVENT_TYPE,WX) : LayoutAble!(Event,EVENT_TYPE,WX)
{
    // drawable -> rasterable
    void to_raster( Rasterizer!WX rasterizer )
    {
        rasterizer.rasterize( ops );
    }
}


class Rasterizer(WX)
{
    this(WINDOW)( WINDOW window )
    {
        //
    }

    void rasterize(OPS)( ref OPS ops )
    {
        go_center();

        foreach ( ref op; ops )
            final switch ( op.type )
            {
                case OP._         : break;
                case OP.GO_CENTER : go_center(); break;
                case OP.GO        : go( op.go ); break;
                case OP.POINT     : break;
                case OP.POINTAT   : point_at( op.point_at); break;
                case OP.POINTS    : break;
                case OP.LINE      : break;
                case OP.LINES     : break;
                case OP.TRIANGLE  : break;
                case OP.TRIANGLES : break;
                case OP.QUAD      : break;
                case OP.QUADS     : break;
                case OP.CIRCLE    : break;
                case OP.CIRCLES   : break;
                case OP.ARC       : break;
                case OP.ARCS      : break;
            }

        flush();
    }

    void go_center()
    {
        //
    }

    void go( ref Go!WX op )
    {
        //
    }

    void point_at( ref PointAt!WX op )
    {
        //
    }

    void flush()
    {
        //
    }
}

version(XCB):
import xcb.xcb;
import vf.platforms.xcb.types : to_px;
import vf.platform : platform;
import vf.platforms.xcb.types : uint32_t;
class XCBRasterizer(WX,PX) : Rasterizer!(WX)
{
    xcb_connection_t* c;
    xcb_drawable_t    drawable;
    xcb_gcontext_t    gc;
    PX                cur;
    PX                window_size;

    this(WINDOW)( WINDOW window )
    {
        this.c           = platform.c;
        this.drawable    = window.hwnd;
        this.window_size = window.size;

        xcb_screen_t*   screen      = platform.screen;
        xcb_gcontext_t  foreground  = xcb_generate_id( c );
        uint32_t        values_mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
        uint32_t[2]     values      = [ screen.white_pixel, 0 ];

        xcb_create_gc( c, foreground, drawable, values_mask, values.ptr );

        this.gc       = foreground;

        super( window );
    }

    override
    void go_center()
    {
        cur = window_size / 2;
        import std.stdio : writeln;
        writeln( "cur: ", cur );
    }

    override
    void go( ref Go!WX op )
    {
        cur = op.wx.to_px;
    }

    override
    void point_at( ref PointAt!WX op )
    {
        auto px = op.wx.to_px;
        xcb_point_t[1] points = xcb_point_t( px.x, px.y );

        xcb_poly_point( c, XCB_COORD_MODE_PREVIOUS, drawable, gc, /*points_len*/ 1, points.ptr );
    }

    override
    void flush()
    {
        xcb_flush( c );
    }
}
