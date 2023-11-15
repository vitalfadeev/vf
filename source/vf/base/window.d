module vf.base.window;


class Window(Event,EVENT_TYPE)
{
    this(SIZE)( SIZE size, string name="Windows Window", int cmd_show=1 )
    {
        _create_window( cmd_show, size, name );
        _create_renderer();
    }

    void sense( Event* event, EVENT_TYPE event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        //
    }

    // private
    private
    void _create_window( SIZE size, string name, int cmd_show )
    {
        auto c = platform.c;

        // Ask for our window's Id
        hwnd = xcb_generate_id( c );

        //
        immutable(uint)   value_mask = 
            XCB_CW_BACK_PIXEL | 
            XCB_CW_EVENT_MASK;
        immutable(uint[]) value_list = [
            platform.screen.black_pixel,
            XCB_EVENT_MASK_EXPOSURE |
            XCB_EVENT_MASK_KEY_PRESS |
            XCB_EVENT_MASK_KEY_RELEASE |
            XCB_EVENT_MASK_BUTTON_PRESS |
            XCB_EVENT_MASK_BUTTON_RELEASE |
            XCB_EVENT_MASK_POINTER_MOTION |
            XCB_EVENT_MASK_FOCUS_CHANGE |
            XCB_EVENT_MASK_STRUCTURE_NOTIFY,
            0
        ];

        // Create the window
        xcb_create_window( 
            c,                             // Connection          
            XCB_COPY_FROM_PARENT,          // depth (same as root)
            hwnd,                          // window Id           
            platform.screen.root,          // parent window       
            0, 0,                          // x, y                
            size.x, size.y,                // width, height       
            10,                            // border_width        
            XCB_WINDOW_CLASS_INPUT_OUTPUT, // class               
            platform.screen.root_visual,   // visual              
            value_mask,                    // masks
            value_list.ptr                 // not used yet 
        );                                 

        // Map the window on the screen
        xcb_map_window( c, hwnd );

        // Make sure commands are sent before we pause, so window is shown
        xcb_flush( c );
    }


    auto ref move_to_center()
    {
        return this;
    }


    auto ref show()
    {
        return this;
    }


    private
    void _create_renderer()
    {
        //XCBRasterAble!WX os_rasterable = new XCBRasterAble!WX();
    }
}
