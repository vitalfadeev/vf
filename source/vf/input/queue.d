module vf.input.queue;

import vf.input.vf.queue    : VfQueue;
import vf.input.evdev.queue : EvdevQueue;
import vf.input.xcb.queue   : XcbQueue;
import vf.input.event       : Event;


struct Queue
{
    Event front;  // xcb_generic_event_t* front;
    void popFront() {}  
    bool empty() { return true; }

    VfQueue    _vf_queue;
    EvdevQueue _evdev_queue;
      // /dev/input/eventX mouse
      // /dev/input/eventX touch
      // /dev/input/eventX keyboard 1
      // /dev/input/eventX keyboard 2 USB
    XcbQueue   _xcb_queue;
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
//                                                              - out device
//                                                              - out net
//                                                              - out file
//                                                              - out socket
//                                                              - out time
