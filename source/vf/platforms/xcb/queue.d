module vf.platforms.xcb.queue;

version(XCB):
import xcb.xcb;
public import vf.base.queue;
import vf.platforms.xcb.platform : Platform;
import vf.platforms.xcb.event    : Event, EventType;


struct Queue
{
    Event front;  // xcb_generic_event_t* front;
    bool  _started = false;

    pragma( inline, true )
    void popFront()
    {
        import core.stdc.stdlib : free;
        free( front.generic );
        front.generic = xcb_wait_for_event( Platform.instance.c );
    }

    pragma( inline, true )
    bool empty()
    {
        if ( !_started )
        {
            _started = true;
            front.generic = xcb_wait_for_event( Platform.instance.c );
        }

        return ( front.generic is null || front.is_game_over );  // XCB_DESTROY_NOTIFY
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    //pragma( inline, true )
    //void opOpAssign( string op : "~" )( SDL_EventType t )
    //{
    //}
}

