module vf.platforms.xcb.window_manager;

version(XCB):
import xcb.xcb;
import vf.base.window_manager  : BaseWindowManager;
import vf.platforms.xcb.event  : Event, EventType;
import vf.platforms.xcb.window : XCBWindow;

alias TBaseWindowManager = 
    BaseWindowManager!(XCBWindow,xcb_window_t,Event,EventType);

// hwnd -> window
// window -> hwnd
class WindowManager : TBaseWindowManager
{
    alias THIS          = typeof(this);
    alias WindowManager = typeof(this);

    //
    override
    void sense( Event* event, EventType event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        import std.algorithm.searching : countUntil;

        // Free window
        // Sens event to window
        xcb_window_t os_window;

        switch ( event_type )
        {
            case XCB_EXPOSE            : { os_window = event.expose.window; break; }
            case XCB_KEY_PRESS         : { os_window = event.key_press.event; break; }
            case XCB_BUTTON_PRESS      : { os_window = event.button_press.event; break; }
            case XCB_MOTION_NOTIFY     : { os_window = event.motion_notify.event; break; }
            case XCB_ENTER_NOTIFY      : { os_window = event.enter_notify.event; break; }
            case XCB_FOCUS_IN          : { os_window = event.focus_in.event; break; }
            case XCB_VISIBILITY_NOTIFY : { os_window = event.visibility_notify.window; break; }
            case XCB_CREATE_NOTIFY     : { os_window = event.create_notify.window; break; }
            case XCB_UNMAP_NOTIFY      : { os_window = event.unmap_notify.window; break; }
            case XCB_MAP_NOTIFY        : { os_window = event.map_notify.window; break; }
            case XCB_MAP_REQUEST       : { os_window = event.map_request.window; break; }
            case XCB_REPARENT_NOTIFY   : { os_window = event.reparent_notify.window; break; }
            case XCB_CONFIGURE_NOTIFY  : { os_window = event.configure_notify.window; break; }
            case XCB_GRAVITY_NOTIFY    : { os_window = event.gravity_notify.window; break; }
            case XCB_RESIZE_REQUEST    : { os_window = event.resize_request.window; break; }
            case XCB_CIRCULATE_NOTIFY  : { os_window = event.circulate_notify.window; break; }
            case XCB_PROPERTY_NOTIFY   : { os_window = event.property_notify.window; break; }
            case XCB_SELECTION_CLEAR   : { os_window = event.selection_clear.owner; break; }
            case XCB_SELECTION_REQUEST : { os_window = event.selection_request.owner; break; }
            case XCB_COLORMAP_NOTIFY   : { os_window = event.colormap_notify.window; break; }
            case XCB_CLIENT_MESSAGE    : { os_window = event.client_message.window; break; }
            case XCB_DESTROY_NOTIFY    : { os_window = event.destroy_notify.window;
                auto i = _os_windows.countUntil( os_window );
                if ( i != -1 ) {
                    _vf_windows[i].sense( event, event_type );
                    unregister( event.destroy_notify.window );
                }
                return;
            }
            default: return;
        }

        auto i = _os_windows.countUntil( os_window );
        if ( i != -1 )
        {
            auto _window = _vf_windows[i];
            event.window = _window;
            _window.sense( event, event_type );
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
