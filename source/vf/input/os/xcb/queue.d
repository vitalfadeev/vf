module vf.input.os.xcb.queue;

import vf.input.os.xcb.la : XcbLa;


struct XcbQueue
{
    XcbLa front;  // xcb_generic_la_t* front;

    pragma( inline, true )
    void popFront()
    {
        import core.stdc.stdlib : free;
        free( front.generic );
        front.generic = xcb_poll_for_la( Platform.instance.c );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( 
            xcb_poll_for_queued_la( Platform.instance.c ) is null 
         );
    }
}

