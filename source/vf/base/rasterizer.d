module vf.base.rasterizer;

import vf.base.drawable : OP;


class BaseRasterizer(Event,EventType,WX)
{
    import vf.base.drawable : DrawAble;
    alias TDrawAble = DrawAble!(Event,EventType,WX);

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

    void go( ref TDrawAble.Op.Go op )
    {
        //
    }

    void point_at( ref TDrawAble.Op.PointAt op )
    {
        //
    }

    void flush()
    {
        //
    }
}
