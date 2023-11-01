module vf.platforms.xcb.queue;

version(XCB):
import xcb.xcb;
public import vf.base.queue;
import vf.platform : platform;
import vf.platforms.xcb.event;
import vf.platforms.xcb.window : Window;


struct Queue
{
    Event* front;  // xcb_generic_event_t* front;
    bool   started = false;

    pragma( inline, true )
    void popFront()
    {
        import std.stdio : writeln;
        writeln( __FUNCTION__ );

        import core.stdc.stdlib : free;
        free( front );
        front = cast(Event*)xcb_wait_for_event( platform.c );
    }

    pragma( inline, true )
    bool empty()
    {
        import std.stdio : writeln;
        writeln( __FUNCTION__, " started: ", started );
        writeln( __FUNCTION__, " platform.c: ", platform.c );

        if ( !started )
        {
            started = true;
            writeln( __FUNCTION__, " xcb_wait_for_event: ", xcb_wait_for_event( platform.c ) );
            //c = cast(Event*)xcb_wait_for_event( platform.c );

            if ( front !is null && front.type == 0 ) 
            {
                import std.stdio : writeln;
                writeln( __FUNCTION__, " front.type: ", front.type );
                writeln( __FUNCTION__, " xcb_generic_error_t: ", *cast(xcb_generic_error_t*)front );
            }
        }

        writeln( __FUNCTION__, " front: ", front );

        return ( front is null );  // XCB_DESTROY_NOTIFY
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    //pragma( inline, true )
    //void opOpAssign( string op : "~" )( SDL_EventType t )
    //{
    //}
}

