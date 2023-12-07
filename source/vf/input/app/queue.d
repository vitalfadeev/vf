module vf.input.app.queue;

import vf.input.app.la : AppLa;
import vf.input.app.la : ElementUpdatedLa;


struct AppQueue
{
    AppLa[] _las;
    alias _las this;

    import std.range;
    alias front    = std.range.front;
    alias empty    = std.range.empty;
    alias popFront = std.range.popFront;

    void put( AppLa la )
    {
        _las ~= la;
    }

    void put(T)( T la )
        if ( is(T==ElementUpdatedLa) )
    {
        _las ~= AppLa( la );
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

void send_la(T)( T la )
    if ( is(T==AppLa) || is(T==ElementUpdatedLa) )
{
    AppQueue.instance.put( la );
}
