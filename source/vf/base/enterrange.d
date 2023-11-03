module vf.base.enterrange;

import std.range     : InputRange;
import std.range     : front, empty, popFront, moveFront;
import vf.interfaces : IEnterAble;
import vf.interfaces : IEnterRange;
import vf.interfaces : ISensAble;


class EnterRange : IEnterRange
{
    alias E = ISensAble;

    E[] _range;


    E    front() { return _range.front; }
    bool empty() { return _range.empty; }
    void popFront() { _range.popFront(); }
    E    moveFront() { return _range.moveFront; }
    void put( E o ) { _range ~= o; }

    int opApply( scope int delegate(E) dg )  {
        int result = 0;

        foreach ( e; _range ) {
            result = dg( e );

            if ( result ) {
                break;
            }
        }

        return result;
    }

    int opApply( scope int delegate(size_t, E) dg )  {
        int result = 0;

        foreach ( i, e; _range ) {
            result = dg( i, e );

            if ( result ) {
                break;
            }
        }

        return result;
    }

    void sense(Event,EVENT_TYPE)( Event* event, EVENT_TYPE event_type )
    {
        foreach( o; _range )
            o.sense( event, event_type );
    }

    E[] find( E sensor )
    {
        import std.algorithm.searching : find;
        return _range.find( sensor );
    }
}
