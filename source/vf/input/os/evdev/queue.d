module vf.input.os.evdev.queue;

import vf.input.cached_queue          : CachedQueue;
import vf.input.os.evdev.la        : EvdevLa;
import vf.input.os.evdev.la        : Timeval;
import vf.input.os.evdev.device_queue : DeviceQueue;

alias TCachedQueue = CachedQueue!(EvdevLa,DeviceQueue);


struct EvdevQueue
{
    EvdevLa* front;

    TCachedQueue[] _queues;

    this( string[] devices )
    {
        foreach( device_file_name; devices )
            _queues ~= TCachedQueue( device_file_name );
    }

    void popFront()
    {        
        Timeval min_timeval = Timeval.max;
        size_t  min_queue_i;
        bool    found;

        foreach ( i, q; _queues )
            if ( !q.empty )
                if ( q.front.input_la.time < min_timeval )
                {
                    min_timeval = q.front.input_la.time;
                    min_queue_i = i;
                    found = true;
                    break;
                }

        //
        if ( found ) {
            auto queue = _queues[ min_queue_i ];
            front = &queue.front;
            queue.popFront();
        }
    }
    
    bool empty()
    {
        import std.algorithm.searching : all;
        return all("empty")( _queues );
    }
}
