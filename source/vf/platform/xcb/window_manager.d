module vf.platform.xcb.window_manager;

version(XCB):
import xcb.xcb;
import vf.interfaces : ISensAble;
import vf.platform.xcb.event : Event, EVENT_TYPE;

// hwnd -> window
// window -> hwnd
class _WindowManager(T,W) : ISensAble
{
    W[] _os_windows;
    T[] _vf_windows;

    T vf_window( W os_window )
    {
        import std.algorithm.searching : countUntil;
        auto i = _os_windows.countUntil( os_window );

        return _vf_windows[i];
    }

    void register( W os_window, T vf_window )
    {
        _os_windows ~= os_window;
        _vf_windows ~= vf_window;
    }

    void unregister( W os_window )
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;
        auto i = _os_windows.countUntil( os_window );
        _os_windows = _os_windows.remove( i );
        _vf_windows = _vf_windows.remove( i );
    }

    // ISense
    void sense( Event* event, EVENT_TYPE event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        import std.algorithm.searching : countUntil;

        switch ( event_type )
        {
            case XCB_DESTROY_NOTIFY: {
                auto os_window = event.destroy_notify.window;
                auto i = _os_windows.countUntil( os_window );
                if ( i != -1 )
                {
                    _vf_windows[i].sense( event, event_type );
                    unregister( event.destroy_notify.window );
                }
                break;
            }
            case XCB_EXPOSE: {
                auto os_window = event.expose.window;
                auto i = _os_windows.countUntil( os_window );
                if ( i != -1 )
                {
                    _vf_windows[i].sense( event, event_type );
                }
                break;
            }
            default: {
                auto os_window = event.expose.window;
                auto i = _os_windows.countUntil( os_window );
                if ( i != -1 )
                {
                    _vf_windows[i].sense( event, event_type );
                }                
            }
        }
    }
}

//import vf.platform.xcb.window_manager : _WindowManager;
import vf.platform.xcb.window : Window;
alias WindowManager = _WindowManager!(Window,xcb_window_t);  // alias xcb_window_t = uint32_t;

WindowManager window_manager;

static
this()
{
    window_manager = new WindowManager();
}