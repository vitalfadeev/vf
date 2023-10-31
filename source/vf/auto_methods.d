module vf.auto_methods;


mixin template auto_sensable(T)
{
    import vf : Event, EVENT_TYPE;
    import vf : VF_DRAW;

    void sense( Event* event, EVENT_TYPE event_type )
    {
        mixin( _auto_sensable!( T, event, event_type )() );

        // recursive
        static if ( hasInterface!( T, IEnterAble ) )
            enter.sense( event, event_type );
    }
}

string _auto_sensable( T, alias event, alias event_type )()
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


mixin template auto_enterable(T)
{
    import std.range;
    import vf.interfaces : IEnterAble;

    IEnterRange _enter;
    
    @property
    IEnterRange enter() 
    {
        return _enter;
    }
}


mixin template auto_drawable(T)
{
    //DrawAble _drawable;

    void point( int x, int y )
    {
        //_drawable.point( x, y );
    }

    void on_VF_DRAW( Event* event, EVENT_TYPE event_type )
    {
        draw();
    }
}


mixin template auto_methods(T)
{
    import vf.interfaces : IEnterAble, ISensAble;
    import vf.traits : hasInterface;

    static if ( hasInterface!( T, IEnterAble ) )
        mixin auto_enterable!(typeof(this));

    static if ( hasInterface!( T, IDrawAble ) )
        mixin auto_drawable!(typeof(this));    

    static if ( hasInterface!( T, ISensAble ) )
        mixin auto_sensable!(typeof(this));    
}
