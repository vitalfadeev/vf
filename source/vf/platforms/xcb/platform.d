module vf.platforms.xcb.platform;

version(XCB):
import xcb.xcb;
public import vf.base.platform;


struct Platform
{
    xcb_connection_t *c;
    xcb_screen_t     *screen;

    void go_init()
    {
        import vf.platforms.xcb.exception : XCBException;
        import core.stdc.stdlib           : getenv;

        // Open the connection to the X server 
        c = xcb_connect( getenv( "DISPLAY" ), null );
        if ( xcb_connection_has_error( c ) )
            throw new XCBException( "Cannot open display", c );

        // Get the first screen
        screen = xcb_setup_roots_iterator( xcb_get_setup( c ) ).data;
    }

    static
    typeof(this)* instance()
    {
        static typeof(this)* _instance;
        
        if ( _instance is null )
        {
            _instance = new typeof(this);
            _instance.go_init();
        }

        return _instance;
    }
}
