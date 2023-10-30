module vf.platform.xcb.ui.window_manager;

version(XCB):
import xcb.xcb;
import vf.sensor;
import vf.event;

// hwnd -> window
// window -> hwnd
class _WindowManager(T,W) : ISensor
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

    void sense( Event* event, EVENT_TYPE event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        import vf.types : show_throwable;

        try {
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
                default: {}
            }
        } 
        catch ( Throwable o ) { o.show_throwable; }
    }
}


import vf.ui.window : Window;
alias WindowManager = _WindowManager!(Window,xcb_window_t);  // alias xcb_window_t = uint32_t;
