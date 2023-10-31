module vf.interfaces;

import std.range : InputRange;
import vf : Event, EVENT_TYPE;
public import vf : ISense;


//
interface IEnterAble
{
    @property IEnterRange enter();
}

interface IEnterRange
{
    void put( ISensAble o );
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

class EnterRange : IEnterRange
{
    ISensAble[] _range;

    void put( ISensAble o )
    {
        _range ~= o;
    }

    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach( o; _range )
            o.sense( event, event_type );
    }
}

//
interface IDrawAble
{
    void point( int x, int y );
}

interface ISensAble
{
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}
