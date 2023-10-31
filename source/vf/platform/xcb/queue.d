module vf.platform.xcb.queue;

version(XCB):
import xcb.xcb;
import vf.platform;
import vf.platform.xcb.event;
import vf.platform.xcb.window : Window;


struct Queue
{
    Event* front;  // xcb_generic_event_t* front;
    bool   started = false;

    pragma( inline, true )
    void popFront()
    {
        if ( !started )
            started = true;
        else
        {
            import core.stdc.stdlib : free;
            free( front );
            front = cast(Event*)xcb_wait_for_event( platform.c );
        }
    }

    pragma( inline, true )
    bool empty()
    {
        if ( !started )
            front = cast(Event*)xcb_wait_for_event( platform.c );

        return ( front is null );  // XCB_DESTROY_NOTIFY
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    //pragma( inline, true )
    //void opOpAssign( string op : "~" )( SDL_EventType t )
    //{
    //}
}

