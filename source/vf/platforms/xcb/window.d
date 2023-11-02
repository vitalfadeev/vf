module vf.platforms.xcb.window;

version(XCB):
import xcb.xcb;
public import vf.base.window;
import vf.platform      : platform;
import vf.event         : Event, EVENT_TYPE;
import vf.interfaces    : IWindow, ISensAble;
import vf.types         : PX;


class Window : IWindow, ISensAble
{
    xcb_window_t hwnd;

    alias T = typeof(this);


    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( cmd_show, size, name );
        _create_renderer();
    }

    // ISense
    void sense( Event* event, EVENT_TYPE event_type ) 
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        //
    }

    // private
    private
    void _create_window( int cmd_show, PX size, string name )
    {
        auto c = platform.c;

        // Ask for our window's Id
        hwnd = xcb_generate_id( c );

        //
        uint    mask   = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
        uint[2] values = [
            platform.screen.white_pixel,
            XCB_EVENT_MASK_EXPOSURE       | XCB_EVENT_MASK_BUTTON_PRESS   |
            XCB_EVENT_MASK_BUTTON_RELEASE | XCB_EVENT_MASK_POINTER_MOTION |
            XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   |
            XCB_EVENT_MASK_KEY_PRESS      | XCB_EVENT_MASK_KEY_RELEASE 
        ];

        // Create the window
        xcb_create_window( 
            c,                             // Connection          
            0,                             // depth (same as root)
            hwnd,                          // window Id           
            platform.screen.root,          // parent window       
            0, 0,                          // x, y                
            size.x, size.y,                // width, height       
            10,                            // border_width        
            XCB_WINDOW_CLASS_INPUT_OUTPUT, // class               
            platform.screen.root_visual,   // visual              
            0, values.ptr                  // masks, not used yet 
        );                                 

        // Map the window on the screen
        xcb_map_window( c, hwnd );

        // Make sure commands are sent before we pause, so window is shown
        xcb_flush( c );
        
        xcb_generic_event_t *event;
        while ( ( event = xcb_wait_for_event( c ) ) !is null ) {
            import std.stdio : writeln;
            writeln( __FUNCTION__, ": ", event.response_type );
            import core.stdc.stdlib : free;
            free (event);
        }
    }


    auto ref move_to_center()
    {
        return this;
    }


    auto ref show()
    {
        return this;
    }


    private
    void _create_renderer()
    {
        //
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
