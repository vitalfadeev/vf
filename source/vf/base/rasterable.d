module vf.base.rasterable;

import vf.base.drawable;
alias PX = int;


struct Rasterable
{
    auto to_raster(D)( D drawable )
    {
        foreach( ref op; drawable.ops )
        {
            final
            switch ( op.type )
            {
                case OP._         : break;
                case OP.GO_CENTER : go_center(); break;
                case OP.GO        : go( op.go.ox.to_px ); break;
                case OP.POINT     : point() ; break;
                case OP.POINTS    : break;
                case OP.POINTS    : break;
                case OP.LINE      : line( op.line.ox.to_px ); break;
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

    pragma( inline, true )
    void go_center()
    {
        //
    }

    pragma( inline, true )
    void go( PX px )
    {
        //
    }

    pragma( inline, true )
    void point()
    {
        //
    }

    pragma( inline, true )
    void line( PX px )
    {
        //
    }
}
