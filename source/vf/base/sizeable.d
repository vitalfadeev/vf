module vf.base.sizeable;

import std.typecons     : Tuple;
import vf.base.drawable : DrawAble;


enum SIZE_MODE
{
    OUTER = 1,
    FIXED = 2,
    INTER = 3,
}

class SizeAble(Event,EventType,WX) : DrawAble!(Event,EventType,WX)
{
    Size!WX   _size;
    SIZE_MODE size_mode;

    void calc_size()
    {
        _size = Size!WX( ops.calc_size() );
    }

    ref Size!WX size()
    {
        return _size;
    }
}

//
void update_sizes(Event,EventType,WX)( LayoutAble!(Event,EventType,WX) e )
{
    e.each_recursive( &e.calc_size );
}

struct Size(WX)
{
    WX a;
    WX b;

    this( Tuple!(WX, "a", WX, "b") t )
    {
        a = t.a;
        b = t.b;
    }

    void grow( Size!WX other )
    {
        // min
        if ( other.a.x < a.x  )
            a.x = other.a.x;

        if ( other.a.y < a.y )
            a.y = other.a.y;

        // max
        if ( other.b.x > b.x  )
            b.x = other.b.x;

        if ( other.b.y > b.y )
            b.y = other.b.y;
    }
}
