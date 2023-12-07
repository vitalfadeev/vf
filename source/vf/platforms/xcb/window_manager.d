module vf.platforms.xcb.window_manager;

version(XCB):
import xcb.xcb;
import vf.base.window_manager  : BaseWindowManager;
import vf.platforms.xcb.la  : La, LaType;
import vf.platforms.xcb.window : XCBWindow;

alias TBaseWindowManager = 
    BaseWindowManager!(XCBWindow,xcb_window_t,La,LaType);

// hwnd -> window
// window -> hwnd
class WindowManager : TBaseWindowManager
{
    alias THIS          = typeof(this);
    alias WindowManager = typeof(this);

    //
    override
    void sense( La* la, LaType la_type )
    //    this         la             la_type
    //    RDI          RSI               RDX
    {
        import std.algorithm.searching : countUntil;

        // Free window
        // Sens la to window
        xcb_window_t os_window;

        switch ( la_type )
        {
            case XCB_EXPOSE            : { os_window = la.expose.window; break; }
            case XCB_KEY_PRESS         : { os_window = la.key_press.la; break; }
            case XCB_BUTTON_PRESS      : { os_window = la.button_press.la; break; }
            case XCB_MOTION_NOTIFY     : { os_window = la.motion_notify.la; break; }
            case XCB_ENTER_NOTIFY      : { os_window = la.enter_notify.la; break; }
            case XCB_FOCUS_IN          : { os_window = la.focus_in.la; break; }
            case XCB_VISIBILITY_NOTIFY : { os_window = la.visibility_notify.window; break; }
            case XCB_CREATE_NOTIFY     : { os_window = la.create_notify.window; break; }
            case XCB_UNMAP_NOTIFY      : { os_window = la.unmap_notify.window; break; }
            case XCB_MAP_NOTIFY        : { os_window = la.map_notify.window; break; }
            case XCB_MAP_REQUEST       : { os_window = la.map_request.window; break; }
            case XCB_REPARENT_NOTIFY   : { os_window = la.reparent_notify.window; break; }
            case XCB_CONFIGURE_NOTIFY  : { os_window = la.configure_notify.window; break; }
            case XCB_GRAVITY_NOTIFY    : { os_window = la.gravity_notify.window; break; }
            case XCB_RESIZE_REQUEST    : { os_window = la.resize_request.window; break; }
            case XCB_CIRCULATE_NOTIFY  : { os_window = la.circulate_notify.window; break; }
            case XCB_PROPERTY_NOTIFY   : { os_window = la.property_notify.window; break; }
            case XCB_SELECTION_CLEAR   : { os_window = la.selection_clear.owner; break; }
            case XCB_SELECTION_REQUEST : { os_window = la.selection_request.owner; break; }
            case XCB_COLORMAP_NOTIFY   : { os_window = la.colormap_notify.window; break; }
            case XCB_CLIENT_MESSAGE    : { os_window = la.client_message.window; break; }
            case XCB_DESTROY_NOTIFY    : { os_window = la.destroy_notify.window;
                auto i = _os_windows.countUntil( os_window );
                if ( i != -1 ) {
                    _vf_windows[i].sense( la, la_type );
                    unregister( la.destroy_notify.window );
                }
                return;
            }
            default: return;
        }

        auto i = _os_windows.countUntil( os_window );
        if ( i != -1 )
        {
            auto _window = _vf_windows[i];
            la.window = _window;
            _window.sense( la, la_type );
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
