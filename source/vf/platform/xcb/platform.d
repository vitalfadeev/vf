module vf.platform.xcb.platform;

version(XCB):
import xcb.xcb;


struct Platform
{
    xcb_connection_t *c;
    xcb_screen_t     *screen;

    @disable 
    this();

    void do_init()
    {
        import vf.platform.xcb.types : XCBException;
        import core.stdc.stdlib      : getenv;

        // Open the connection to the X server 
        c = xcb_connect( getenv( "DISPLAY" ), null );
        if ( xcb_connection_has_error( c ) )
            throw new XCBException( "Cannot open display", c );

        // Get the first screen
        screen = xcb_setup_roots_iterator( xcb_get_setup( c ) ).data;
    }
}
