module vf.platforms.windows.window_manager;

version(WINDOWS):
import core.sys.windows.windows;
public import vf.base.window_manager;
import vf.interfaces              : ISensAble, IWindow;
import vf.platforms.windows.event : Event, EVENT_TYPE;

// hwnd -> window
// window -> hwnd
class WindowManager : vf.base.window_manager.WindowManager!(IWindow,HWND), ISensAble
{

    void sense( Event* event, EVENT_TYPE event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
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
}
