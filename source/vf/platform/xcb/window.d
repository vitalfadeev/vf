module vf.platform.xcb.window;

version(XCB):
import xcb.xcb;
import vf.platform;
import vf.event;
import vf.sensor;
import vf.window_manager;
import vf.types : PX;


class Window : ISensor
{
    xcb_window_t hwnd;

    alias T = typeof(this);


    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( cmd_show, size, name );
        _create_renderer();
    }

    // ISensor
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
        window_manager.register( hwnd, this );

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
            0, null                        // masks, not used yet 
        );                                 

        // Map the window on the screen
        xcb_map_window( c, hwnd );

        // Make sure commands are sent before we pause, so window is shown
        xcb_flush( c );
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

    static 
    WindowManager window_manager;
}


void auto_route_event(T)( T This, Event* event, EVENT_TYPE event_type )
{
    import std.traits;
    import std.string;
    import std.format;
    import vf.traits;

    // on_
    mixin( _auto_route_event!(Handlers!T)() );
}


string _auto_route_event(T)()
{
    string s = "switch ( event_type ) {";
        
    static foreach( h; T )
    {
        s ~= 
            "case __traits( identifier, h )[3..$] {
                h( event, event_type ); 
                break;
            }";
    }
        s ~= 
            "default:";

    s ~= "}";

    return s;
}


static
this()
{
    Window.window_manager = new WindowManager();
}
