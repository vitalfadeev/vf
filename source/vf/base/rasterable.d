module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.drawable   : OP;


class RasterAble(Event,EVENT_TYPE,WX) : LayoutAble!(Event,EVENT_TYPE,WX)
{
    // drawable -> rasterable
    void to_raster( ref OSRasterAble rasterable )
    {
        foreach ( ref op; ops )
            final switch ( op.type )
            {
                case OP._         : break;
                case OP.GO_CENTER : rasterable.go_center(); break;
                case OP.GO        : break;
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


class OSRasterAble
{
    void go_center()
    {
        //
    }
}
