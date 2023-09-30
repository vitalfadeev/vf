module vf.painter;

import std.stdio;
import vf.types;


class Painter
{
    Ops ops;


    auto ref go_center()
    {
        ops ~= GoCenter();
        return this;
    }

    auto ref go( W w, H h )
    {
        ops ~= Go( OP.GO, OX( w, h ) );
        return this;
    }

    auto ref point()
    {
        ops ~= Point();
        return this;
    }

    auto ref line( W w, H h )
    {
        ops ~= Line( OP.LINE, OX( w,h ) );
        return this;
    }


    //
    import vf.platform.windows.raster;
    import vf.platform.windows.ui.window;
    auto to(T:Raster,WINDOW:Window)( WINDOW window, HDC hdc )
    {
        // rasterize
        auto raster = vf.platform.windows.ui.window.to!Raster( window, hdc );

        foreach( op; ops )
        {
            final
            switch ( op.type )
            {
                case OP._         : break;
                case OP.GO_CENTER : raster.go_center(); break;
                case OP.GO        : raster.go( op.go.ox.to!PX ); break;
                case OP.POINT     : raster.point() ; break;
                case OP.LINE      : raster.line( op.line.ox.to!PX ); break;
            }
        }

        return raster;
    }

    auto to(T:File)( string filename )
    {
        // header
        //   SG version
        // operations
        //   type
        //   args

        struct SGFile_Operation
        {
            //
        }

        struct SGFile_Header
        {
            M8[4]               magic = [ 'S', 'G', '0', '1' ];
            M16                 header_size;
            SGFile_Operation[0] operations;
        }

        auto f = File( filename, "w" );

        SGFile_Header header;
        f.rawWrite( ( cast(ubyte*)&header )[0..header.sizeof] );

        return f;
    }
}

auto from(T:File)( string filename )
{
    auto painter = new Painter();
    return painter;
}


enum OP
{
    _,
    GO_CENTER,
    GO,
    POINT,
    LINE,
}


struct Op
{
    union 
    {
        OP       type;
        GoCenter go_center;
        Go       go;
        Point    point;
        Line     line;
    }

    this( GoCenter b )
    {
        go_center = b;
    }

    this( Go b )
    {
        go = b;
    }

    this( Point b )
    {
        point = b;
    }

    this( Line b )
    {
        line = b;
    }
}

struct GoCenter
{
    OP type = OP.GO_CENTER;
}

struct Go
{
    OP type = OP.GO;
    OX ox;
}

struct Point
{
    OP type = OP.POINT;
}

struct Line
{
    OP type = OP.LINE;
    OX ox;
}


//
struct Ops
{
    Op[] _super;
    alias _super this;

    void opOpAssign(string op:"~")( GoCenter b )
    {
        _super ~= Op( b );
    }

    void opOpAssign(string op:"~")( Go b )
    {
        _super ~= Op( b );
    }

    void opOpAssign(string op:"~")( Point b )
    {
        _super ~= Op( b );
    }

    void opOpAssign(string op:"~")( Line b )
    {
        _super ~= Op( b );
    }
}


T to(T:PX)( OX ox )
{
    T px;
    px.x = ox.x;
    px.y = ox.y;
    return px;
}
