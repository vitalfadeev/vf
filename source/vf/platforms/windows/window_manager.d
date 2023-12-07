module vf.platforms.windows.window_manager;

version(WINDOWS):
import core.sys.windows.windows;
public import vf.base.window_manager;
import vf.interfaces              : ISensAble, IWindow;
import vf.platforms.windows.la : La, LaType;

// hwnd -> window
// window -> hwnd
class WindowManager : vf.base.window_manager.WindowManager!(IWindow,HWND), ISensAble
{

    void sense( La* la, LaType la_type )
    //    this         la             la_type
    //    RDI          RSI               RDX
    {
        import std.algorithm.searching : countUntil;

        switch ( la_type )
        {
            case WM_DESTROY: {
                auto os_window = la.msg.hwnd;
                auto i = _os_windows.countUntil( os_window );
                if ( i != -1 )
                {
                    _vf_windows[i].sense( la, la_type );
                    unregister( la.msg.hwnd );
                }
                break;
            }
            //case WM_PAINT: {
            //    auto os_window = la.expose.window;
            //    auto i = _os_windows.countUntil( os_window );
            //    if ( i != -1 )
            //    {
            //        _vf_windows[i].sense( la, la_type );
            //    }
            //    break;
            //}
            default: {}
        }
    }
}
