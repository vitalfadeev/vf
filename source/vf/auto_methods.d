module vf.auto_methods;


mixin template auto_sense(T)
{
    import vf : Event, EVENT_TYPE;

    void sense( Event* event, EVENT_TYPE event_type )
    {
        mixin( _auto_sense!( T, event, event_type )() );
    }
}

string _auto_sense( T, alias event, alias event_type )()
{
    import std.traits;
    import std.string;
    import std.format;
    import vf.traits;

    string s;
    s ~= "switch (event_type) {";

    static foreach( h; Handlers!T )
        s ~= "case "~(HandlerName!h)[3..$]~":  { this."~(HandlerName!h)~"( event, event_type ); break; } ";

    //
        s ~= "default: {}";

    s ~= "}";

    return s;
}


mixin template auto_outer(T)
{
    import vf.interfaces : IInner;

    IInner _inner;
    
    @property
    IInner inner() 
    {
        return _inner;
    }
}



mixin template auto_methods(T)
{
    import vf.interfaces : IOuter, ISense;
    import vf.traits : hasInterface;

    static if ( hasInterface!( T, IOuter ) )
        mixin auto_outer!(typeof(this));

    static if ( hasInterface!( T, ISense ) )
        mixin auto_sense!(typeof(this));
    
    //mixin auto_draw!(typeof(this));
}
