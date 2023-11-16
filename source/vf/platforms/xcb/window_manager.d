module vf.platforms.xcb.window_manager;

version(XCB):
import xcb.xcb;
import vf.base.window_manager  : BaseWindowManager;
import vf.base.window          : BaseWindow;
import vf.platforms.xcb.event  : Event, EVENT_TYPE;
import vf.platforms.xcb.window : Window;

alias TBaseWindow = BaseWindow!(Event,EVENT_TYPE);

// hwnd -> window
// window -> hwnd
class WindowManager : BaseWindowManager!(TBaseWindow,xcb_window_t,Event,EVENT_TYPE)
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

    static
    typeof(this) instance()
    {
        static typeof(this) _instance;
        
        if ( _instance is null )
            _instance = new typeof(this);

        return _instance;
    }
}

//alias ManagedWindow = vf.base.window_manager.ManagedWindow!(Window,xcb_window_t,Event,EVENT_TYPE);

