module vf.auto_methods;


mixin template auto_sensable(T)
{
    import vf.la : La, LaType;
    import vf       : VF_DRAW;

    override
    void sense( La* la, LaType la_type )
    {
        mixin( _auto_sensable!( T, la, la_type )() );

        // recursive
        static if ( hasInterface!( T, IEnterAble ) )
            enter.sense( la, la_type );

        super.sense( e, la_type );
    }
}

string _auto_sensable( T, alias la, alias la_type )()
{
    import std.traits;
    import std.string;
    import std.format;
    import vf.traits;

    string s;
    s ~= "switch (la_type) {";

    static foreach( h; Handlers!T )
        s ~= "case "~(HandlerName!h)[3..$]~":  { this."~(HandlerName!h)~"( la, la_type ); break; } ";

    //
        s ~= "default: {}";

    s ~= "}";

    return s;
}


mixin template auto_enterable(T)
{
    import vf.element    : EnterElement;
    import vf.interfaces : IEnterAble;

    EnterElement enter;
    
    void put( Element b )
    {
        enter.put( b );
    }
}


mixin template auto_drawable(T)
{
    import vf.drawable;

    //mixin DrawAble!T;

    void on_VF_DRAW( La* la, LaType la_type )
    {
        draw();
    }
}


mixin template auto_methods(T)
{
    import vf.interfaces : IEnterAble, IDrawAble, ISensAble;
    import vf.traits : hasInterface;
    import vf.auto_methods : auto_enterable;
    import vf.auto_methods : auto_drawable;
    import vf.auto_methods : auto_sensable;


    static if ( hasInterface!( T, IEnterAble ) )
        mixin auto_enterable!(typeof(this));

    static if ( hasInterface!( T, IDrawAble ) )
        mixin auto_drawable!(typeof(this));    

    static if ( hasInterface!( T, ISensAble ) )
        mixin auto_sensable!(typeof(this));    
}


mixin template auto_cap(T)
{
    uint auto_cap = mixin( _get_cap!T );
}
string _get_cap(T)()
{
    import std.format : format;
    import std.string : toUpper;
    import vf.traits : interfaces_of, interface_name;

    string s;

    s ~= "CAP._";

    static foreach( I; interfaces_of!T )
        s ~= format!" | CAP.%s"( interface_name!I.toUpper );

    return s;
}
