module vf.platform.windows.ui.window_manager;

version(WINDOWS):
import core.sys.windows.windows;
import vf.event;
import vf.sensor;

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
                case WM_DESTROY: {
                    auto os_window = event.msg.hwnd;
                    auto i = _os_windows.countUntil( os_window );
                    if ( i != -1 )
                    {
                        _vf_windows[i].sense( event, event_type );
                        unregister( event.msg.hwnd );
                    }
                    break;
                }
                //case WM_PAINT: {
                //    auto os_window = event.expose.window;
                //    auto i = _os_windows.countUntil( os_window );
                //    if ( i != -1 )
                //    {
                //        _vf_windows[i].sense( event, event_type );
                //    }
                //    break;
                //}
                default: {}
            }
        } 
        catch ( Throwable o ) { o.show_throwable; }
    }


    extern( Windows ) 
    static nothrow
    LRESULT window_proc_sense( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
    {   //              RCX,       RDX,            R8,            R9
        import vf : show_throwable;

        Event event;
        event.msg.message = message;
        event.msg.hwnd    = hwnd;
        event.msg.wParam  = wParam;
        event.msg.lParam  = lParam;
        alias event_type  = message;
        try {
            window_manager.sense( &event, event_type );
        } catch ( Throwable o ) { o.show_throwable; }
        return DefWindowProc( hwnd, message, wParam, lParam );
    }
}


import vf.ui.window : Window;
alias WindowManager = _WindowManager!(Window,HWND);  // alias xcb_window_t = uint32_t;

WindowManager window_manager;

static
this()
{
    window_manager = new WindowManager();
}