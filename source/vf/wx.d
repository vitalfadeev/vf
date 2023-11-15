module vf.wx;

import vf.base.wx;


version(XCB)
{
    import std.typecons  : Tuple;
    import vf.base.fixed : Fixed;

    struct WX
    {
        vf.base.wx.WX!( Fixed, Fixed ) _super;
        alias _super this;

        this( int x, int y )
        {
            _super = vf.base.wx.WX!( Fixed(x), Fixed(y) );
        }

        this( Tuple!(Fixed, "x", Fixed, "y") t )
        {
            _super = vf.base.wx.WX!( t.x, t.y );
        }

        void opOpAssign( string op : "+" )( WX b )
        {
            x += b.x;
            y += b.y;
        }
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
