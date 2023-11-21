module vf.input.evdev.queue;

import vf.input.cached_queue       : CachedQueue;
import vf.input.evdev.event        : EvdevEvent;
import vf.input.evdev.device_queue : DeviceQueue;

alias TCachedQueue = CachedQueue!(EvdevEvent,DeviceQueue);
alias Timestamp    = typeof( EvdevEvent.input_event.time.tv_sec );


struct EvdevQueue
{
    EvdevEvent* front;

    TCachedQueue[] _queues;

    this( string[] devices )
    {
        foreach( device_file_name; devices )
            _queues ~= TCachedQueue( device_file_name );
    }

    void popFront()
    {        
        Timestamp min_timestamp;
        size_t    min_queue_i;

        foreach ( i, q; _queues )
            if ( !q.empty )
                if ( q.front.input_event.time.tv_sec < min_timestamp )
                {
                    min_timestamp = q.front.input_event.time.tv_sec;
                    min_queue_i   = i;
                    break;
                }

        //
        if ( min_timestamp )
        {        
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
