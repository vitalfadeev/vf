module vf.platform.linux.ui.window_xcb;

version(LINUX_X11):
import xcb.xcb;  // x11.xcb
import vf.types;
import vf.ui.window_interface;

class Window : IWindow  
{
    xcb_window_t* w;

    xcb_connection_t *c;
    xcb_screen_t     *screen;
    xcb_window_t      win;


    alias T = typeof(this);


    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( cmd_show, size, name );
        _create_renderer();
    }

    //
    LRESULT event( EVENT_TYPE event_type, Event* event ) 
    {
        return DefWindowProc( hwnd, cast(UINT)e, cast(WPARAM)code, cast(LPARAM)value );
    }

    // private
    private
    void _create_window( int cmd_show, PX size, string name )
    {
        // Open the connection to the X server 
        c = xcb_connect( NULL, NULL );

        // Get the first screen
        screen = xcb_setup_roots_iterator( xcb_get_setup(c) ).data;

        // Ask for our window's Id
        win = xcb_generate_id( c );

        // Create the window
        xcb_create_window( 
            c,                             // Connection          
            XCB_COPY_FROM_PARENT,          // depth (same as root)
            win,                           // window Id           
            screen.root,                   // parent window       
            0, 0,                          // x, y                
            size.x, size.y,                // width, height       
            10,                            // border_width        
            XCB_WINDOW_CLASS_INPUT_OUTPUT, // class               
            screen.root_visual,            // visual              
            0, NULL                        // masks, not used yet 
        );                                 

        // Map the window on the screen
        xcb_map_window( c, win );

        // Make sure commands are sent before we pause, so window is shown
        xcb_flush( c );
    }


    auto ref move_to_center()
    {
        RECT rect;
        GetWindowRect( hwnd, &rect );

        auto ws = GetSystemMetrics( SM_CXSCREEN );
        auto hs = GetSystemMetrics( SM_CYSCREEN );

        SetWindowPos(
          hwnd,
          null,
          (ws - (rect.right - rect.left))/2,
          (hs - (rect.bottom - rect.top))/2,
          0,
          0,
          SWP_NOSIZE | SWP_NOZORDER | SWP_ASYNCWINDOWPOS
        );

        return this;
    }


    auto ref show()
    {
        ShowWindow( hwnd, 1 );
        UpdateWindow( hwnd ); 

        return this;
    }


    private
    void _create_renderer()
    {
        //
    }


    // hwnd -> window
    // window -> hwnd
    static
    struct WindowManager
    {
        static HWND[] _os_windows;
        static T[]    _vf_windows;

        static
        T vf_window( HWND hwnd )
        {
            import std.algorithm.searching : countUntil;
            auto i = _os_windows.countUntil( hwnd );

            return _vf_windows[i];
        }

        static 
        void register( HWND hwnd, Window _this )
        {
            _os_windows ~= hwnd;
            _vf_windows ~= _this;
        }

        static nothrow
        void unregister( HWND hwnd )
        {
            import std.algorithm.searching : countUntil;
            import std.algorithm.mutation : remove;
            auto i = _os_windows.countUntil( hwnd );
            _os_windows = _os_windows.remove( i );
            _vf_windows = _vf_windows.remove( i );
        }

        extern( Windows ) 
        static nothrow
        LRESULT event( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
        {   //              RCX,       RDX,            R8,            R9
            // Microsoft x64 calling convention:
            //   RCX, RDX, R8, R9
            try {
                import std.algorithm.searching : countUntil;
                auto i = _os_windows.countUntil( hwnd );
                if ( i != -1 )
                {
                    if ( message == WM_DESTROY )
                    {
                        auto ret = _vf_windows[i].event( Event(message), EventCode(wParam), EventValue(lParam) );
                        unregister( hwnd );
                        return ret;
                    }
                    else
                    {
                        return _vf_windows[i].event( Event(message), EventCode(wParam), EventValue(lParam) );
                    }
                }
            } 
            catch (Throwable o) { o.show_throwable; }

            return DefWindowProc( hwnd, message, wParam, lParam );
        }
    }
}


ERESULT auto_route_event(T)( T This, EVENT_TYPE event_type, Event* event )
{
    import std.traits;
    import std.string;
    import std.format;

    // on_
    static foreach( m; __traits( allMembers, T ) )
        static if ( isCallable!(__traits(getMember, T, m)) )
            static if ( m.startsWith( "on_" ) )
                if ( e == mixin( m[3..$] ) )
                    return __traits(getMember, This, m)( event_type, event ); 

    return;
}
