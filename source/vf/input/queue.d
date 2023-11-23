module vf.input.queue;

import vf.input.vf.queue    : VfQueue;
import vf.input.evdev.queue : EvdevQueue;
import vf.input.xcb.queue   : XcbQueue;
import vf.input.event       : Event;

    
struct Queue
{
    Event* front;  // xcb_generic_event_t* front;

    void popFront()
    {
        // select
        //   !empty
        //   min timestamp
        //     front
        //     popFront

        //_vf_queue.popFront();
        //_evdev_queue.popFront();
        //_xcb_queue.popFront();
        enum MinQueueId
        {
            _,
            VF,
            XCB,
            EVDEV,
        }

        Timestamp  min_timestamp;
        MinQueueId min_queue;

        if ( !_vf_queue.front.empty )
            if ( _vf_queue.front.timestamp < min_timestamp )
            {
                min_timestamp = _vf_queue.front.timestamp;
                min_queue = MinQueueId.VF;
            }

        if ( !_xcb_queue.front.empty )
            if ( _xcb_queue.front.timestamp < min_timestamp )
            {
                min_timestamp = _xcb_queue.front.timestamp;
                min_queue = MinQueueId.XCB;
            }

        if ( !_evdev_queue.front.empty )
            if ( _evdev_queue.front.timestamp < min_timestamp )
            {
                min_timestamp = _evdev_queue.front.timestamp;
                min_queue = MinQueueId.EVDEV;
            }

        //
        final switch ( min_queue )
        {
            case MinQueue._: 
                break;
            case MinQueue.VF: 
                front = &_vf_queue.front;
                _vf_queue.popFront();
                break;
            case MinQueue.XCB: 
                front = &_xcb_queue.front;
                _xcb_queue.popFront();
                break;
            case MinQueue.EVDEV: 
                front = &_evdev_queue.front;
                _evdev_queue.popFront();
                break;
        }
    }  

    bool empty() 
    { 
        return ( 
            _vf_queue.empty && 
            _evdev_queue.empty && 
            _xcb_queue.empty 
        ); 
    }


    VfQueue    _vf_queue;
    XcbQueue   _xcb_queue;
    EvdevQueue _evdev_queue;
      // /dev/input/eventX mouse
      // /dev/input/eventX touch
      // /dev/input/eventX keyboard 1
      // /dev/input/eventX keyboard 2 USB
}

// in                                        processor            out
// sensor     queue                  event   selector    action   actor
// --------   -----   ------------   -----   ---------   ------   ----------
// vf       - queue - 
// evdev    -       - by timestamp -
// xcb      -                      - event -
// net      -                              - .sense()  - 
// file     -                                          - action - 
// socket   -                                                   - vf event
// timer    -                                                   - func()
// udev     -                                                   - out device
// dbus     -                                                   - out net
// inotify  -                                                   - out file
//                                                              - out socket
//                                                              - out time

