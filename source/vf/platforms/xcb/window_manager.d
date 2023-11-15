module vf.platforms.xcb.window_manager;

version(XCB):
import xcb.xcb;
public import vf.base.window_manager;
import vf.platforms.xcb.event : Event, EVENT_TYPE;
import vf.base.oswindow       : OSWindow;

// hwnd -> window
// window -> hwnd
class WindowManager : vf.base.window_manager.WindowManager!(ManagedWindow,xcb_window_t,Event,EVENT_TYPE)
{
    //
    override
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

alias ManagedWindow = vf.base.window_manager.ManagedWindow!(OSWindow!(xcb_window_t,Event,EVENT_TYPE),xcb_window_t,Event,EVENT_TYPE);

