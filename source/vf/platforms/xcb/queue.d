module vf.platforms.xcb.queue;

version(XCB):
import xcb.xcb;
public import vf.base.queue;
import vf.platforms.xcb.platform : Platform;
import vf.platforms.xcb.la    : La, LaType;

// evdev
//   mice - driver - kernel - evdev (timestamp) - program
//    /dev/input/laX
// keyboard
//   ...
// mousedev
//    /dev/input/mouseX
//    /dev/input/mice
// joydev
//    /dev/input/jsX

//struct input_la {
//    timeval time;  // long, long
//    ushort  type;
//    ushort  code;
//    uint    value;
//}
//
//struct timeval
//{
//    time_t      tv_sec;   // long
//    suseconds_t tv_usec;  // long 
//}

// pause until
//   xcb
//   evdev
//   net
//   timer
//   local socket
//   pipe
//   process
// vf not paused, because prog

// ACTIVATE_WINDOW
//   connect to evdev /dev/las/*       (mouse,keyvoard,joystick)
//   or enable input
// DEACTIVATE_WINDOW
//   disconnect from evdev /dev/las/*  (mouse,keyvoard,joystick)
//   or disable input


//struct Queue
//{
//    La front;  // xcb_generic_la_t* front;

//    pragma( inline, true )
//    void popFront()  
//    {
//        // find max timestamp
//        //   timestamp
//        //   sequence
//        //   time

//        // selector
//        //   0b0000: all empty
//        //   0b0001: vf
//        //   0b0010: xcb
//        //   0b0011: vf+xcb
//        enum Selector : ubyte {
//            _      = 0b0000,
//            VF     = 0b0001,
//            XCB    = 0b0010,
//            XCB_VF = 0b0011,
//        }

//        ubyte _selector;
//        if ( !_vf_queue.empty )
//            _selector |= Selector.VF;
//        if ( !_xcb_queue.empty )
//            _selector |= Selector.XCB;

//        switch ( _selector )
//        {
//            case Selector._: {
//                break;
//            }
//            case Selector.VF: {
//                front      = _vf_queue.front;
//                _vf_queue.popFront();
//                break;
//            }
//            case Selector.XCB: {
//                front      = _xcb_queue.front;
//                _xcb_queue.popFront();
//                break;
//            }
//            case Selector.XCB_VF: {
//                La.Timestamp _vf_time;   // 
//                La.Timestamp _xcb_time;  // xcb_timestamp_t = uint
//                _vf_time   = _vf_queue.front.timestamp;
//                _xcb_time  = _xcb_queue.front.timestamp;

//                if ( _vf_time <= _xcb_time )
//                {
//                    front  = _vf_queue.front;
//                    _vf_queue.popFront();
//                }
//                else
//                {
//                    front  = _xcb_queue.front;
//                    _xcb_queue.popFront();
//                }
//                break;
//            }
//            default:
//        }
//    }

//    pragma( inline, true )
//    bool empty()
//    { 
//        // wait for la
//        //  loop:
//        //   check
//        //   if empty
//        //     wait
//        //     goto loop
//        return ( _vf_queue.empty && _xcb_queue.empty );
//    }

//    // la readers
//    //   XCB
//    //   VF
//    VFQueue  _vf_queue;
//    XCBQueue _xcb_queue;
//}


//struct XCBQueue
//{
//    La front;  // xcb_generic_la_t* front;

//    pragma( inline, true )
//    void popFront()
//    {
//        import core.stdc.stdlib : free;
//        free( front.generic );
//        front.generic = xcb_poll_for_la( Platform.instance.c );
//    }

//    pragma( inline, true )
//    bool empty()
//    {
//        return ( 
//            xcb_poll_for_queued_la( Platform.instance.c ) is null 
//         );
//    }
//}

