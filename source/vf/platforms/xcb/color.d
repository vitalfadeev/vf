module vf.platforms.xcb.color;

version(XCB):
import xcb.xcb;
import vf.platforms.xcb.types;

alias Color = uint;


struct Colors
{   //                           RRGGBB
    static Color primary   = 0xFFFFFFFF;
    static Color secondary = 0xFF22FF22;
}


// xcb_colormap_t    colormap;
// colormap = screen->default_colormap;
//
// xcb_colormap_t xcb_generate_id (xcb_connection_t *c);
// xcb_void_cookie_t xcb_create_colormap (xcb_connection_t *c,       /* Pointer to the xcb_connection_t structure */
//                                        uint8_t           alloc,   /* Colormap entries to be allocated (AllocNone or AllocAll) */
//                                        xcb_colormap_t    mid,     /* Id of the color map */
//                                        xcb_window_t      window,  /* Window on whose screen the colormap will be created */
//                                        xcb_visualid_t    visual); /* Id of the visual supported by the screen */
//

//struct xcb_alloc_color_reply_t {
//    uint8_t    response_type;
//    uint8_t    pad0;
//    uint16_t   sequence;
//    uint32_t   length;
//    uint16_t   red;          /* The red component   */
//    uint16_t   green;        /* The green component */
//    uint16_t   blue;         /* The blue component  */
//    uint8_t[2] pad1;
//    uint32_t   pixel;        /* The entry in the color map, supplied by the X server */
//}

//xcb_alloc_color_cookie_t xcb_alloc_color       (xcb_connection_t        *c,
//                                                xcb_colormap_t           cmap,
//                                                uint16_t                 red,
//                                                uint16_t                 green,
//                                                uint16_t                 blue);
//xcb_alloc_color_reply_t *xcb_alloc_color_reply (xcb_connection_t        *c,
//                                                xcb_alloc_color_cookie_t cookie,
//                                                xcb_generic_error_t    **e);

