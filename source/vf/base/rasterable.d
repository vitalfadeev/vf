module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.drawable   : OP;
import vf.base.drawable   : Go;


class RasterAble(Event,EVENT_TYPE,WX) : LayoutAble!(Event,EVENT_TYPE,WX)
{
    // drawable -> rasterable
    void to_raster( ref Rasterizer!WX rasterizer )
    {
        rasterizer.rasterize( ops );
    }
}


class Rasterizer(WX)
{
    void rasterize(OPS)( ref OPS ops )
    {
        foreach ( ref op; ops )
            final switch ( op.type )
            {
                case OP._         : break;
                case OP.GO_CENTER : go_center(); break;
                case OP.GO        : go( op.go ); break;
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
class XCBRasterizer(WX) : Rasterizer!(WX)
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
