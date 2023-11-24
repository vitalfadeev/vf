module vf.input.vf.queue;

import vf.input.vf.event : VfEvent;
import vf.input.vf.event : ElementUpdatedEvent;


struct VfQueue
{
    VfEvent[] _events;
    alias _events this;

    import std.range;
    alias front    = std.range.front;
    alias empty    = std.range.empty;
    alias popFront = std.range.popFront;

    void put( VfEvent event )
    {
        _events ~= event;
    }

    void put(T)( T event )
        if ( is(T==ElementUpdatedEvent) )
    {
        _events ~= VfEvent( event );
    }

    static
    typeof(this) instance()
    {
        static typeof(this) _instance;
        
        if ( _instance is null )
            _instance = new typeof(this);

        return _instance;
    }
}

void send_event(T)( T event )
    if ( is(T==VfEvent) || is(T==ElementUpdatedEvent) )
{
    VfQueue.instance.put( event );
}
