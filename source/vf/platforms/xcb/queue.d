module vf.platforms.xcb.queue;

version(XCB):
import xcb.xcb;
public import vf.base.queue;
import vf.platforms.xcb.platform : Platform;
import vf.platforms.xcb.event    : Event, EventType;


struct Queue
{
    Event front;  // xcb_generic_event_t* front;

    pragma( inline, true )
    void popFront()  
    {
        // find max timestamp
        //   timestamp
        //   sequence
        //   time

        // selector
        //   0b0000: all empty
        //   0b0001: vf
        //   0b0010: xcb
        //   0b0011: vf+xcb
        enum Selector : ubyte {
            _      = 0b0000,
            VF     = 0b0001,
            XCB    = 0b0010,
            XCB_VF = 0b0011,
        }

        ubyte _selector;
        if ( !_vf_queue.empty )
            _selector |= Selector.VF;
        if ( !_xcb_queue.empty )
            _selector |= Selector.XCB;

        switch ( _selector )
        {
            case Selector._: {
                break;
            }
            case Selector.VF: {
                front      = _vf_queue.front;
                _vf_queue.popFront();
                break;
            }
            case Selector.XCB: {
                front      = _xcb_queue.front;
                _xcb_queue.popFront();
                break;
            }
            case Selector.XCB_VF: {
                Event.Timestamp _vf_time;   // 
                Event.Timestamp _xcb_time;  // xcb_timestamp_t = uint
                _vf_time   = _vf_queue.front.timestamp;
                _xcb_time  = _xcb_queue.front.timestamp;

                if ( _vf_time <= _xcb_time )
                {
                    front  = _vf_queue.front;
                    _vf_queue.popFront();
                }
                else
                {
                    front  = _xcb_queue.front;
                    _xcb_queue.popFront();
                }
                break;
            }
            default:
        }
    }

    pragma( inline, true )
    bool empty()
    { 
        // wait for event
        //  loop:
        //   check
        //   if empty
        //     wait
        //     goto loop
        return ( _vf_queue.empty && _xcb_queue.empty );
    }

    // event readers
    //   XCB
    //   VF
    VFQueue  _vf_queue;
    XCBQueue _xcb_queue;
}


struct VFQueue
{
    import std.range : front, empty, popFront;

    Event[] _events;

    pragma( inline, true )
    Event front() @property
    {
        return _events.front;
    }

    pragma( inline, true )
    void popFront() 
    {
        _events.popFront();
    }

    pragma( inline, true )
    bool empty() 
    { 
        return _events.empty;
    }
}

struct XCBQueue
{
    Event front;  // xcb_generic_event_t* front;

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

