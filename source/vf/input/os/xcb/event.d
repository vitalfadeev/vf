module vf.input.os.xcb.la;

version(XCB):
import xcb.xcb;
import vf.base.timeval : Timeval;


struct XcbLa
{
    Timeval   timeval;
    LaType la_type;

    union {
        ubyte                         type;
        xcb_generic_la_t*          generic;
        xcb_key_press_la_t*        key_press;
        xcb_button_press_la_t*     button_press;
        xcb_motion_notify_la_t*    motion_notify;
        xcb_enter_notify_la_t*     enter_notify;
        xcb_focus_in_la_t*         focus_in;
        xcb_keymap_notify_la_t*    keymap_notify;
        xcb_expose_la_t*           expose;
        xcb_graphics_exposure_la_t*graphics_exposure;
        xcb_no_exposure_la_t*      no_exposure;
        xcb_visibility_notify_la_t*visibility_notify;
        xcb_create_notify_la_t*    create_notify;
        xcb_destroy_notify_la_t*   destroy_notify;
        xcb_unmap_notify_la_t*     unmap_notify;
        xcb_map_notify_la_t*       map_notify;
        xcb_map_request_la_t*      map_request;
        xcb_reparent_notify_la_t*  reparent_notify;
        xcb_configure_notify_la_t* configure_notify;
        xcb_configure_request_la_t*configure_request;
        xcb_gravity_notify_la_t*   gravity_notify;
        xcb_resize_request_la_t*   resize_request;
        xcb_circulate_notify_la_t* circulate_notify;
        xcb_property_notify_la_t*  property_notify;
        xcb_selection_clear_la_t*  selection_clear;
        xcb_selection_request_la_t*selection_request;
        xcb_selection_notify_la_t* selection_notify;
        xcb_colormap_notify_la_t*  colormap_notify;
        xcb_client_message_la_t*   client_message;
        xcb_mapping_notify_la_t*   mapping_notify;
        xcb_ge_generic_la_t*       ge_generic;
    }

    alias LaType = typeof ( type );
}

