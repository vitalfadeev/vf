module vf.platforms.xcb.event;

version(XCB):
import xcb.xcb;
import vf.base.event;
import vf.base.sensable        : SensAble;
import vf.platforms.xcb.wx     : WX;
import vf.platforms.xcb.window : XCBWindow;
import vf.platforms.xcb.world  : World;


struct SX 
{
    short x;
    short y;
}

struct Event
{
    union {
        xcb_generic_event_t           generic;
        xcb_key_press_event_t         key_press;
        xcb_button_press_event_t      button_press;
        xcb_motion_notify_event_t     motion_notify;
        xcb_enter_notify_event_t      enter_notify;
        xcb_focus_in_event_t          focus_in;
        xcb_keymap_notify_event_t     keymap_notify;
        xcb_expose_event_t            expose;
        xcb_graphics_exposure_event_t graphics_exposure;
        xcb_no_exposure_event_t       no_exposure;
        xcb_visibility_notify_event_t visibility_notify;
        xcb_create_notify_event_t     create_notify;
        xcb_destroy_notify_event_t    destroy_notify;
        xcb_unmap_notify_event_t      unmap_notify;
        xcb_map_notify_event_t        map_notify;
        xcb_map_request_event_t       map_request;
        xcb_reparent_notify_event_t   reparent_notify;
        xcb_configure_notify_event_t  configure_notify;
        xcb_configure_request_event_t configure_request;
        xcb_gravity_notify_event_t    gravity_notify;
        xcb_resize_request_event_t    resize_request;
        xcb_circulate_notify_event_t  circulate_notify;
        xcb_property_notify_event_t   property_notify;
        xcb_selection_clear_event_t   selection_clear;
        xcb_selection_request_event_t selection_request;
        xcb_selection_notify_event_t  selection_notify;
        xcb_colormap_notify_event_t   colormap_notify;
        xcb_client_message_event_t    client_message;
        xcb_mapping_notify_event_t    mapping_notify;
        xcb_ge_generic_event_t        ge_generic;
        //
        DrawEvent draw;
        // world_offset
        // add_world_offset = T delegate( wx )
        XCBWindow window;
        World     world;
        WX        world_offset;
    }

    auto type()
    {
        //return generic.response_type & ~0x80;
        return generic.response_type;
    }

    SensAble!(Event,EventType) dst()
    {
        return null;
    }

    Source src()  // event source. device
    {
        return null;
    }

    bool is_game_over()
    {
        return ( generic.response_type == XCB_GAME_OVER );
    }

    bool is_draw()
    {
        return ( generic.response_type == XCB_DRAW );
    }

    string toString()
    {
        import std.format : format;
        return format!"Event( 0x%04X )"(generic.response_type);
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
}

alias EventType = uint;

enum : EventType {
    XCB_DRAW      = 0x80_01,
    XCB_GAME_OVER = 0x80_02,
}

import vf.interfaces : IDrawAble;
struct DrawEvent
{
    EventType type = XCB_DRAW;
    IDrawAble drawable;
}

