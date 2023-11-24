module vf.input.xcb.queue;

import vf.input.xcb.event : XcbEvent;


struct XcbQueue
{
    XcbEvent front;  // xcb_generic_event_t* front;

    pragma( inline, true )
    void popFront()
    {
        import core.stdc.stdlib : free;
        free( front.generic );
        front.generic = xcb_poll_for_event( Platform.instance.c );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( 
            xcb_poll_for_queued_event( Platform.instance.c ) is null 
         );
    }
}

