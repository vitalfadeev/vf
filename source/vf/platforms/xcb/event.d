module vf.platforms.xcb.la;

version(XCB):
import xcb.xcb;
import vf.base.la;
import vf.base.sensable        : SensAble;
import vf.platforms.xcb.wx     : WX;
import vf.platforms.xcb.window : XCBWindow;
import vf.platforms.xcb.world  : World;


struct SX 
{
    short x;
    short y;
}

struct La
{
    alias Timestamp = uint;  // xcb_timestamp_t = uint

    union {
        xcb_generic_la_t*           generic;
        xcb_key_press_la_t*         key_press;
        xcb_button_press_la_t*      button_press;
        xcb_motion_notify_la_t*     motion_notify;
        xcb_enter_notify_la_t*      enter_notify;
        xcb_focus_in_la_t*          focus_in;
        xcb_keymap_notify_la_t*     keymap_notify;
        xcb_expose_la_t*            expose;
        xcb_graphics_exposure_la_t* graphics_exposure;
        xcb_no_exposure_la_t*       no_exposure;
        xcb_visibility_notify_la_t* visibility_notify;
        xcb_create_notify_la_t*     create_notify;
        xcb_destroy_notify_la_t*    destroy_notify;
        xcb_unmap_notify_la_t*      unmap_notify;
        xcb_map_notify_la_t*        map_notify;
        xcb_map_request_la_t*       map_request;
        xcb_reparent_notify_la_t*   reparent_notify;
        xcb_configure_notify_la_t*  configure_notify;
        xcb_configure_request_la_t* configure_request;
        xcb_gravity_notify_la_t*    gravity_notify;
        xcb_resize_request_la_t*    resize_request;
        xcb_circulate_notify_la_t*  circulate_notify;
        xcb_property_notify_la_t*   property_notify;
        xcb_selection_clear_la_t*   selection_clear;
        xcb_selection_request_la_t* selection_request;
        xcb_selection_notify_la_t*  selection_notify;
        xcb_colormap_notify_la_t*   colormap_notify;
        xcb_client_message_la_t*    client_message;
        xcb_mapping_notify_la_t*    mapping_notify;
        xcb_ge_generic_la_t*        ge_generic;
    }
    //
    DrawLa draw;
    // world_offset
    // add_world_offset = T delegate( wx )
    XCBWindow window;
    World     world;
    WX        world_offset;
    WX        button_press_wx;

    auto type()
    {
        //return generic.response_type & ~0x80;
        return generic.response_type;
    }

    SensAble!(La,LaType) dst()
    {
        return null;
    }

    Source src()  // la source. device
    {
        return null;
    }

    Timestamp timestamp()
    {
        return 0;
    }

    bool is_game_over()
    {
        return ( generic.response_type == XCB_GAME_OVER );
    }

    bool is_draw()
    {
        return ( generic.response_type == XCB_DRAW );
    }

    //
    class Source
    {
        WX to_wx( SX sx )
        {
            return WX( sx.x, sx.y );
        }
    }
    class MouseSource : Source
    {
        override
        WX to_wx( SX sx )
        {
            return WX( sx.x, sx.y );
        }
    }

    string toString()
    {
        import std.format : format;
        return format!"La( 0x%04X )"(generic.response_type);
    }
}

alias LaType = uint;

enum : LaType {
    XCB_DRAW      = 0x80_01,
    XCB_GAME_OVER = 0x80_02,

    VF_DRAW            = 0x80_03,
    VF_REDRAW          = 0x80_04,
    VF_BUTTON_PRESSED  = 0x80_05,
    VF_BUTTON_RELEASED = 0x80_06,
    VF_ELEMENT_UPDATED = 0x80_07,  // or VF_ELEMENT_DRAW_REQUEST
    // ...
    VF_GAME_OVER       = 0x80_FF,
}

import vf.interfaces : IDrawAble;
struct DrawLa
{
    LaType type = XCB_DRAW;
    IDrawAble drawable;
}


/*
 * Tell the given window that it was configured to a size of 800x600 pixels.
 */
import vf.platforms.xcb.element : Element;
void send_la( LaType la_type, Element element ) 
{
    //
    // Every X11 la is 32 bytes long. Therefore, XCB will copy 32 bytes.
    // In order to properly initialize these bytes, we allocate 32 bytes even
    // though we only need less for an xcb_configure_notify_la_t
    //
    import core.stdc.stdlib : calloc;
    xcb_configure_notify_la_t* la = 
        cast( xcb_configure_notify_la_t* )calloc( 32, 1 );

    la.response_type = cast(ubyte)la_type;

    import vf.platforms.xcb.platform : Platform;
    xcb_connection_t* c = Platform.instance.c;

    //XCB_CLIENT_MESSAGE
    //xcb_send_la( c, false, window, XCB_EVENT_MASK_STRUCTURE_NOTIFY, cast(char*)la );

    xcb_flush( c );
    
    import core.stdc.stdlib : free;
    free( la );
}
