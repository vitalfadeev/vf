module vf.platforms.xcb.window;

version(XCB):
import xcb.xcb;
import vf.base.window;
import vf.platform      : platform;
import vf.event         : Event, EVENT_TYPE;
import vf.interfaces    : IWindow, ISensAble;
import vf.types         : PX;
import vf.base.oswindow : OSWindow;

alias XCBWindow = OSWindow!(xcb_window_t,Event,EVENT_TYPE);

class Window : XCBWindow, IWindow, ISensAble
{
    alias T = typeof(this);

    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( size, name, cmd_show );
        _create_renderer();
    }

    //
    override
    void sense( Event* event, EVENT_TYPE event_type ) 
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        switch (event_type)
        {
            case XCB_EXPOSE: on_XCB_EXPOSE( event, event_type ); break;
            default:
        }
        super.sense( event, event_type );
    }



    override
    void move_to_center()
    {
        //
    }


    override
    void show()
    {
        //
    }


    // private
    void _create_window( PX size, string name, int cmd_show )
    {
        auto c = platform.c;

        // Ask for our window's Id
        hwnd = xcb_generate_id( c );

        //
        immutable(uint)   value_mask = 
            XCB_CW_BACK_PIXEL | 
            XCB_CW_EVENT_MASK;
        immutable(uint[]) value_list = [
            platform.screen.black_pixel,
            XCB_EVENT_MASK_EXPOSURE |
            XCB_EVENT_MASK_KEY_PRESS |
            XCB_EVENT_MASK_KEY_RELEASE |
            XCB_EVENT_MASK_BUTTON_PRESS |
            XCB_EVENT_MASK_BUTTON_RELEASE |
            XCB_EVENT_MASK_POINTER_MOTION |
            XCB_EVENT_MASK_FOCUS_CHANGE |
            XCB_EVENT_MASK_STRUCTURE_NOTIFY,
            0
        ];

        // Create the window
        xcb_create_window( 
            c,                             // Connection          
            XCB_COPY_FROM_PARENT,          // depth (same as root)
            hwnd,                          // window Id           
            platform.screen.root,          // parent window       
            0, 0,                          // x, y                
            size.x, size.y,                // width, height       
            10,                            // border_width        
            XCB_WINDOW_CLASS_INPUT_OUTPUT, // class               
            platform.screen.root_visual,   // visual              
            value_mask,                    // masks
            value_list.ptr                 // not used yet 
        );                                 

        // Map the window on the screen
        xcb_map_window( c, hwnd );

        // Make sure commands are sent before we pause, so window is shown
        xcb_flush( c );
    }

    void _create_renderer()
    {
        //XCBRasterAble!WX os_rasterable = new XCBRasterAble!WX();
    }

    //
    void on_XCB_EXPOSE( Event* event, EVENT_TYPE event_type ) 
    {
        import vf.platforms.xcb.types : uint32_t;

        auto expose = event.expose;
        auto c      = platform.c;

        //OSRasterAble!WX os_rasterable = new XCBRasterAble!WX();
        //world.to_raster( os_rasterable );

        ////
        //xcb_point_t[] points = [
        //    {10, 10},
        //    {10, 20},
        //    {20, 10},
        //    {20, 20}
        //];

        //xcb_point_t[] polyline = [
        //    {50, 10},
        //    { 5, 20},     /* rest of points are relative */
        //    {25,-20},
        //    {10, 10}
        //];

        ///* Create black (foreground) graphic context */
        //xcb_gcontext_t foreground = xcb_generate_id( c );
        //uint32_t       value_mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
        //uint32_t[]     value_list = [ platform.screen.white_pixel, 0 ];

        //xcb_create_gc( c, foreground, hwnd, value_mask, value_list.ptr );

        ////
        //xcb_poly_point( c, XCB_COORD_MODE_ORIGIN,   hwnd, foreground, 4, points.ptr );
        //xcb_poly_line(  c, XCB_COORD_MODE_PREVIOUS, hwnd, foreground, 4, polyline.ptr );

        //xcb_flush( c );
        //import std.stdio : writeln;
        //writeln( __FUNCTION__  );
    }
}


void auto_route_event( alias This, alias event, alias event_type )()
{
    mixin( _auto_route_event!( This, event, event_type )() );
}

string _auto_route_event( alias This, alias event, alias event_type )()
{
    import std.traits;
    import std.string;
    import std.format;
    import vf.traits;

    alias T = typeof( This );

    string s;
    s ~= "import xcb.xcb;";

    s ~= "switch (event_type) {";

    static foreach( h; Handlers!T )
        s ~= "case "~(HandlerName!h)[3..$]~":  { This."~(HandlerName!h)~"( event, event_type ); break; } ";

    //
        s ~= "default: {}";

    s ~= "}";

    return s;
}
