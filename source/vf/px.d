module vf.px;


struct PX
{
    version(DEFAULT)
    {
        short x;  // total: 32 bit
        short y;  //        
    }

    version(VECTOR)
    {
        int   xy;
        short x() @property { return xy & 0xFFFF0000 >> 16; }
        short y() @property { return xy & 0xFFFF; }
    }

    version(XCB)
    {
        import xcb.xcb : xcb_point_t;
        
        xcb_point_t _xcb_point;
        alias _xcb_point this;
        // xcb_point_t
        //   int16_t x;
        //   int16_t y;
    }
}
