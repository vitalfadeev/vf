module vf.input.queue;

import vf.input.os.queue    : OsQueue;
import vf.input.usr.queue   : UsrQueue;
import vf.input.app.queue   : AppQueue;
import vf.input.la          : La;


static shared La* la;


// source 
//   0x0000..0x03FF =  os ( windows, linux, evdev, dbus, xcb )
//   0x0400..0x7FFF = usr 
//   0x8000..0xFFFF = app ( app, app_timer )
    
struct 
Queue {
    alias front = .la;  // xcb_generic_la_t* front;

    void 
    popFront () {
        // select
        //   !empty
        //   min timeval
        //     front
        //     popFront

        // _os_queue.popFront();
        // _usr_queue.popFront();
        // _app_queue.popFront();
        enum 
        MinQueueId {
            _,
            OS,
            USR,
            APP,
        }

        Timeval    min_timeval;
        MinQueueId min_queue;

        if ( !_os_queue.front.empty )
            if ( _os_queue.front.timeval < min_timeval ) {
                min_timeval = _os_queue.front.timeval;
                min_queue = MinQueueId.VF;
            }

        if ( !_usr_queue.front.empty )
            if ( _usr_queue.front.timeval < min_timeval ) {
                min_timeval = _usr_queue.front.timeval;
                min_queue = MinQueueId.XCB;
            }

        if ( !_app_queue.front.empty )
            if ( _app_queue.front.timeval < min_timeval ) {
                min_timeval = _app_queue.front.timeval;
                min_queue = MinQueueId.EVDEV;
            }

        //
        final switch ( min_queue ) {
            case MinQueue._: 
                break;
            case MinQueue.OS: 
                front = &_os_queue.front;
                _os_queue.popFront();
                break;
            case MinQueue.USR: 
                front = &_usr_queue.front;
                _usr_queue.popFront();
                break;
            case MinQueue.APP: 
                front = &_app_queue.front;
                _app_queue.popFront();
                break;
        }
    }  

    bool 
    empty () { 
        return ( 
            _os_queue.empty && 
            _usr_queue.empty && 
            _app_queue.empty 
        ); 
    }


    static typeof(this) 
    instance () {
        static typeof(this) _instance;
        
        if ( _instance is null )
            _instance = new typeof(this);

        return _instance;
    }

    OsQueue  _os_queue;
    UsrQueue _usr_queue;
    AppQueue _app_queue;

    // OS
    //   /dev/input/laX mouse
    //   /dev/input/laX touch
    //   /dev/input/laX keyboard 1
    //   /dev/input/laX keyboard 2 USB
    //   /run/user/1000/bus
    // USR
    //   ...
    // APP
    //   ...

    // OS
    //   by_poll + time
    // USR
    //   by_time
    // APP
    //   by_time
}

// in                                        processor            out
// sensor     queue                  la   selector    action   actor
// --------   -----   ------------   -----   ---------   ------   ----------
// vf       - queue - 
// evdev    -       - by timeval -
// xcb      -                      - la -
// net      -                              - .sense()  - 
// file     -                                          - action - 
// socket   -                                                   - vf la
// timer    -                                                   - func()
// udev     -                                                   - out device
// dbus     -                                                   - out net
// inotify  -                                                   - out file
//                                                              - out socket
//                                                              - out time

