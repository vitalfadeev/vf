module vf.platforms.xcb.wx;

import vf.base.wx : BaseWX;

version(XCB)
struct WX
{
    import std.typecons  : Tuple;
    import vf.base.fixed : Fixed;

    alias TBaseWX = BaseWX!( Fixed, Fixed );

    TBaseWX _super;
    alias _super this;

    this( int x, int y )
    {
        _super = TBaseWX( Fixed(x,0), Fixed(y,0) );
    }

    this( Tuple!(Fixed, "x", Fixed, "y") t )
    {
        _super = TBaseWX( t.x, t.y );
    }

    void opOpAssign( string op : "+" )( WX b )
    {
        x += b.x;
        y += b.y;
    }
}



version(DEFAULT)
struct WX
{           // fixed 16.16
    int x;  // total: 64 biy 
    int y;  // 
}

version(VECTOR)
struct WX
{
    long xy;
    int  x() @property { return xy & 0xFFFFFFFF00000000 >> 32; }
    int  y() @property { return xy & 0xFFFFFFFF; }
}
