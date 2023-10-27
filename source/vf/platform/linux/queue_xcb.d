module vf.platform.linux.queue_xcb;

version (LINUX_X11):
import xcb.xcb;
import vf.types;


struct Queue
{
    xcb_generic_event_t* front;

    xcb_connection_t    *c;
    xcb_screen_t        *screen;
    xcb_window_t         win;
    xcb_gcontext_t       g;
    xcb_generic_event_t *e;
    uint32_t             mask;
    uint32_t[2]          values;

    this()
    {
        // open connection to the server
        c = xcb_connect(NULL,NULL);
        if ( xcb_connection_has_error(c) )
            throw new LinuxX11XCBException( "Cannot open display", c );

        // get the first screen
        screen = xcb_setup_roots_iterator( xcb_get_setup(c) ).data;

        // create black graphics context
        g = xcb_generate_id(c);
        win = screen.root;
        mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
        values[0] = screen.black_pixel;
        values[1] = 0;
        xcb_create_gc(c, g, win, mask, values);

        // create window
        win = xcb_generate_id(c);
        mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
        values[0] = screen.white_pixel;
        values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_KEY_PRESS;
        xcb_create_window(c, screen.root_depth, win, screen.root,
                          10, 10, 100, 100, 1,
                          XCB_WINDOW_CLASS_INPUT_OUTPUT, screen.root_visual,
                          mask, values);

        // map (show) the window
        xcb_map_window(c, win);

        xcb_flush(c);
    }

    ~this()
    {
        if ( front !is null )
        {
            free( front );
            front = null;
        }

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

        front = xcb_wait_for_event( c );
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

