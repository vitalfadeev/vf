module vf.platform.linux.queue_xcb;

version (LINUX_X11_xcb):
import vf.types;
import xcb;


struct Queue
{
    xcb_generic_event_t* front;

    xcb_connection_t    *c;
    xcb_screen_t        *s;
    xcb_window_t         w;
    xcb_gcontext_t       g;
    xcb_generic_event_t *e;
    uint32_t             mask;
    uint32_t[2]          values;

    this()
    {
        // open connection to the server
        c = xcb_connect(NULL,NULL);
        if (xcb_connection_has_error(c)) {
          printf("Cannot open display\n");
          exit(EXIT_FAILURE);
        }

        // get the first screen
        s = xcb_setup_roots_iterator( xcb_get_setup(c) ).data;

        // create black graphics context
        g = xcb_generate_id(c);
        w = s.root;
        mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
        values[0] = s.black_pixel;
        values[1] = 0;
        xcb_create_gc(c, g, w, mask, values);

        // create window
        w = xcb_generate_id(c);
        mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
        values[0] = s.white_pixel;
        values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_KEY_PRESS;
        xcb_create_window(c, s.root_depth, w, s.root,
                          10, 10, 100, 100, 1,
                          XCB_WINDOW_CLASS_INPUT_OUTPUT, s.root_visual,
                          mask, values);

        // map (show) the window
        xcb_map_window(c, w);

        xcb_flush(c);
    }

    ~this()
    {
        // close connection to server
        xcb_disconnect(c);
    }

    pragma( inline, true )
    void popFront()
    {
        if ( front !is null )
        {
          free( front );
          front = null;
        }

        front = xcb_wait_for_event(c);
    }

    pragma( inline, true )
    bool empty()
    {
        return front is null;
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    //pragma( inline, true )
    //void opOpAssign( string op : "~" )( SDL_EventType t )
    //{
    //}
}

