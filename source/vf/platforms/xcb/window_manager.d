module vf.platforms.xcb.window_manager;

version(XCB):
import xcb.xcb;
import vf.base.window_manager  : BaseWindowManager;
import vf.base.window          : BaseWindow;
import vf.platforms.xcb.event  : Event, EventType;
import vf.platforms.xcb.window : XCBWindow;

alias TBaseWindow = BaseWindow!(Event,EventType);
alias TBaseWindowManager = 
    BaseWindowManager!(TBaseWindow,xcb_window_t,Event,EventType);

// hwnd -> window
// window -> hwnd
class WindowManager : TBaseWindowManager
{
    //
    override
    void sense( Event* event, EventType event_type )
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
