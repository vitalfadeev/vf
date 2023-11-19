module vf.platforms.xcb.rasterizer;


version(XCB):
import xcb.xcb;
import vf.base.rasterizer      : BaseRasterizer;
import vf.platform             : Platform;
import vf.platforms.xcb.types  : uint32_t;

//alias PX = Device.PX;
//alias PX = Window.PX;

//alias Rasterizer = Device.Rasterizer;
//alias Rasterizer = Window.Rasterizer;

class XCBRasterizer(Window,RasterAble) : BaseRasterizer!(RasterAble)
{
    alias PX       = Window.PX;
    alias Platform = .Platform;

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
    void go( ref DrawAble.Op.Go op )
    {
        cur = op.wx.to_px!(PX,WX);
    }

    override
    void point_at( ref DrawAble.Op.PointAt op )
    {
        auto px = cur + op.wx.to_px!(PX,WX);
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
    void color( ref DrawAble.Op.Color op )
    {
        uint32_t mask = XCB_GC_FOREGROUND;
        uint32_t foreground_value = op.color;
        xcb_change_gc( c, gc, mask, &foreground_value );        
    }

    override
    void flush()
    {
        xcb_flush( c );
    }
}


PX to_px(PX,WX)( WX wx )
{
    // Fixed -> short
    return PX( wx.x.a / 2^^16, wx.y.a / 2^^16 );
}
