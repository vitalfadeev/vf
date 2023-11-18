module vf.platforms.xcb.window;

version(XCB):
import xcb.xcb;
import vf.platform                     : Platform;
import vf.base.oswindow                : BaseOSWindow;
import vf.base.rasterable              : RasterAble;
import vf.base.px                      : BasePX;
import vf.platforms.xcb.event          : Event, EventType;
import vf.platforms.xcb.types          : uint16_t;
import vf.platforms.xcb.rasterizer     : XCBRasterizer;
import vf.platforms.xcb.types          : X,Y;
import vf.platforms.xcb.wx             : WX;
import vf.platforms.xcb.window_manager : WindowManager;

alias Window = XCBWindow;


class XCBWindow : BaseOSWindow!(xcb_window_t,Event,EventType)
{
    alias THIS       = typeof(this);
    alias PX         = .BasePX!(X,Y); 
    alias WX         = .WX;
    alias RasterAble = .RasterAble!(Event,EventType,WX);
    alias Rasterizer = .XCBRasterizer!(THIS,RasterAble);
    alias Platform   = .Platform;

    Rasterizer rasterizer;

    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( size, name, cmd_show );
        _create_renderer();
        WindowManager.instance.register( this, this.hwnd );
    }

    //
    override
    void sense( Event* event, EventType event_type ) 
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
        // screen.size() / 2
        // size() / 2
        // move
    }


    override
    void show()
    {
        //
    }


    PX size()
    {
        uint16_t w;
        uint16_t h;
        xcb_get_geometry_cookie_t cookie;
        xcb_get_geometry_reply_t* reply;

        cookie = xcb_get_geometry( Platform.instance.c, hwnd );

       //struct xcb_get_geometry_reply_t {
       //    uint8_t      response_type;
       //    uint8_t      depth;
       //    uint16_t     sequence;
       //    uint32_t     length;
       //    xcb_window_t root;
       //    int16_t      x;
       //    int16_t      y;
       //    uint16_t     width;
       //    uint16_t     height;
       //    uint16_t     border_width;
       //    uint8_t      pad0[2];
       //}

        if ( ( reply = xcb_get_geometry_reply( Platform.instance.c, cookie, null ) ) !is null ) {
            w = reply.width;
            h = reply.height;
        }

        import core.stdc.stdlib : free;
        free( reply );

        return PX( w, h );
    }

    override
    void draw( Event* event, EventType event_type ) 
    {
        //
    }


    // private
    void _create_window( PX size, string name, int cmd_show )
    {
        auto c = Platform.instance.c;

        // Ask for our window's Id
        hwnd = xcb_generate_id( c );

        //
        immutable(uint)   value_mask = 
            XCB_CW_BACK_PIXEL | 
            XCB_CW_EVENT_MASK;
        immutable(uint[]) value_list = [
            Platform.instance.screen.black_pixel,
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
            Platform.instance.screen.root, // parent window       
            0, 0,                          // x, y                
            size.x, size.y,                // width, height       
            10,                            // border_width        
            XCB_WINDOW_CLASS_INPUT_OUTPUT, // class               
            Platform.instance.screen.root_visual, // visual              
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
        rasterizer = new Rasterizer( this );
    }

    //
    void on_XCB_EXPOSE( Event* event, EventType event_type ) 
    {
        draw( event, event_type );
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

    alias THIS = typeof( This );

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
