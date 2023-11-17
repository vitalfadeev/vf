module vf.platforms.xcb.rasterizer;


version(XCB):
import xcb.xcb;
import vf.base.drawable        : OP;
import vf.base.drawable        : Go, PointAt;
import vf.base.rasterizer      : BaseRasterizer;
import vf.platform             : Platform;
//import vf.platforms.xcb.window : Window;
import vf.platforms.xcb.types  : uint32_t;

//alias PX = Device.PX;
//alias PX = Window.PX;

//alias Rasterizer = Device.Rasterizer;
//alias Rasterizer = Window.Rasterizer;

class XCBRasterizer(Window,WX) : BaseRasterizer!(WX)
{
    alias PX = Window.PX;

    xcb_connection_t* c;
    xcb_drawable_t    drawable;
    xcb_gcontext_t    gc;
    PX                cur;
    PX                window_size;
    Window            window;

    this( Window window )
    {
        this.window      = window;
        this.c           = Platform.instance.c;
        this.drawable    = window.hwnd;
        this.window_size = window.size;

        xcb_screen_t*  screen      = Platform.instance.screen;
        xcb_gcontext_t gc          = xcb_generate_id( c );
        uint32_t       values_mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
        uint32_t[2]    values      = [ screen.white_pixel, 0 ];

        xcb_create_gc( c, gc, drawable, values_mask, values.ptr );

        this.gc = gc;
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
        cur = to_px( op.wx );
    }

    override
    void point_at( ref PointAt!WX op )
    {
        auto px = cur + to_px( op.wx );
        import std.stdio : writeln;
        writeln(px);

        // px -> xcb_point_t
        static
        if ( is( typeof( xcb_point_t.x ) == typeof( px.x ) ) &&
             is( typeof( xcb_point_t.y ) == typeof( px.y ) ) )
            xcb_poly_point( c, XCB_COORD_MODE_ORIGIN, drawable, gc, /*points_len*/ 1, cast(xcb_point_t*)&px );
        else
        {
            xcb_point_t[1] points = xcb_point_t( px.x, px.y );
            xcb_poly_point( c, XCB_COORD_MODE_ORIGIN, drawable, gc, /*points_len*/ 1, points.ptr );
        }
    }

    override
    void flush()
    {
        xcb_flush( c );
    }


    static
    PX to_px( WX wx )
    {
        // Fixed -> short
        return PX( wx.x.a >> 16, wx.y.a >> 16 );
    }
}

