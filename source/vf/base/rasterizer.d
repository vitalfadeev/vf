module vf.base.rasterizer;

import vf.base.drawable   : OP;
import vf.base.drawable   : Go, PointAt;


class BaseRasterizer(WX)
{
    this(WINDOW)( WINDOW window )
    {
        //
    }

    void rasterize(OPS)( ref OPS ops )
    {
        go_center();

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

        flush();
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

    void flush()
    {
        //
    }
}
