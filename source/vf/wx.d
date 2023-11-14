module vf.wx;

import vf.base.wx;


version(XCB)
{
    import vf.base.fixed : Fixed;
    struct WX
    {
        vf.base.wx.WX!( Fixed, Fixed ) _super;
        alias _super this;

        this( int x, int y )
        {
            _super = vf.base.wx.WX!( Fixed(x), Fixed(y) );
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
