module vf.platforms.xcb.queue;

version(XCB):
import xcb.xcb;
public import vf.base.queue;
import vf.platform : platform;
import vf.platforms.xcb.event;


struct Queue
{
    Event* front;  // xcb_generic_event_t* front;
    bool   _started = false;

    pragma( inline, true )
    void popFront()
    {
        import core.stdc.stdlib : free;
        free( front );
        front = cast(Event*)xcb_wait_for_event( platform.c );
    }

    pragma( inline, true )
    bool empty()
    {
        if ( !_started )
        {
            _started = true;
            front = cast(Event*)xcb_wait_for_event( platform.c );
        }

        return ( front is null || front.is_game_over );  // XCB_DESTROY_NOTIFY
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    //pragma( inline, true )
    //void opOpAssign( string op : "~" )( SDL_EventType t )
    //{
    //}
}

