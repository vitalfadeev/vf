module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.drawable   : OP;
import vf.base.drawable   : Go;


class RasterAble(Event,EVENT_TYPE,WX) : LayoutAble!(Event,EVENT_TYPE,WX)
{
    // drawable -> rasterable
    void to_raster( ref OSRasterAble!WX rasterable )
    {
        foreach ( ref op; ops )
            final switch ( op.type )
            {
                case OP._         : break;
                case OP.GO_CENTER : rasterable.go_center(); break;
                case OP.GO        : rasterable.go( op.go ); break;
                case OP.POINT     : break;
                case OP.POINTAT   : break;
                case OP.POINTS    : break;
                case OP.LINE      : break;
                case OP.LINES     : break;
                case OP.TRIANGLE  : break;
                case OP.TRIANGLES : break;
                case OP.QUAD      : break;
                case OP.QUADS     : break;
                case OP.CIRCLE    : break;
                case OP.CIRCLES   : break;
                case OP.ARC       : break;
                case OP.ARCS      : break;
            }
    }
}


class OSRasterAble(WX)
{
    void go_center()
    {
        //
    }

    void go( ref Go!WX op )
    {
        //
    }
}

version(XCB)
class XCBRasterAble(WX) : OSRasterAble!(WX)
{
    override
    void go_center()
    {
        //
    }

    override
    void go( ref Go!WX op )
    {
        //
    }
}
