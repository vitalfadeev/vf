module vf.base.rasterizer;

import vf.base.drawable : OP;


class BaseRasterizer(RasterAble)
{
    alias DrawAble = RasterAble;
    alias WX       = RasterAble.WX;

    void rasterize( RasterAble rasterable )
    {
        go_center();

        foreach ( ref op; rasterable.ops )
            final switch ( op.type )
            {
                case OP._         : break;
                case OP.GO_CENTER : go_center(); break;
                case OP.GO        : go( op.go ); break;
                case OP.POINT     : break;
                case OP.POINTAT   : point_at( op.point_at ); break;
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
                case OP.COLOR     : color( op.color ); break;
            }

        flush();
    }

    void go_center()
    {
        //
    }

    void go( ref DrawAble.Op.Go op )
    {
        //
    }

    void point_at( ref DrawAble.Op.PointAt op )
    {
        //
    }

    void color( ref DrawAble.Op.Color op )
    {
        //
    }

    void flush()
    {
        //
    }
}
