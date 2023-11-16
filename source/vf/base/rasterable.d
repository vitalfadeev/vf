module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.drawable   : OP;
import vf.base.drawable   : Go, PointAt;


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
                case OP.POINTAT   : point_at( op.point_at); break;
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

    void point_at( ref PointAt!WX op )
    {
        //
    }
}

version(XCB):
import xcb.xcb;
class XCBRasterizer(WX) : Rasterizer!(WX)
{
    xcb_connection_t* c;
    xcb_drawable_t    drawable;
    xcb_gcontext_t    gc;

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

    override
    void point_at( ref PointAt!WX op )
    {
        xcb_point_t[1] points = xcb_point_t( wx.x >> 16, wx.y >> 16 );

        xcb_poly_point( c, XCB_COORD_MODE_PREVIOUS, drawable, gc, /*points_len*/ 1, points.ptr );
    }
}
