module vf.base.element;

import std.range          : InputRange;
import std.range          : front, empty, popFront, moveFront;
import vf.base.interfaces : IEnterAble;
import vf.base.interfaces : ISensAble;
import vf.base.drawable   : DrawAble;


class Element(Event,EVENT_TYPE) : ISensAble!(Event,EVENT_TYPE), IEnterAble
{
    // ISensAble
    void sense( Event* event, EVENT_TYPE event_type )
    //      this       event             event_type         
    //      RDI        RSI               RDX
    {
        //
    }

    // IEnterAble
    EnterElement!(Event,EVENT_TYPE) enter;

    // IDrawAble
    DrawAble drawable;

    // ILayoutAble
    LayoutAble layoutable;
}


struct EnterElement(Event,EVENT_TYPE)
{
    alias E = Element!(Event,EVENT_TYPE);

    E[] _range;


    E    front()     { return _range.front; }
    bool empty()     { return _range.empty; }
    void popFront()  { _range.popFront(); }
    E    moveFront() { return _range.moveFront; }
    void put( E o )  { _range ~= o; }

    int opApply( scope int delegate(E) dg )  
    {
        int result = 0;

        foreach( e; _range )
            if ( ( result = dg( e ) ) != 0 )
                break;

        return result;
    }

    int opApply( scope int delegate(size_t, E) dg )  
    {
        int result = 0;

        foreach( i, e; _range )
            if ( ( result = dg( i, e ) ) != 0 )
                break;

        return result;
    }

    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach( ref e; _range )
            e.sense( event, event_type );
    }
}
