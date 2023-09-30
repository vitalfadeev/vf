module vf.painter;

import std.stdio;
import vf.types;


class Painter
{
    Op[] ops;


    auto ref go_center()
    {
        return this;
    }

    auto ref go( W w, H h )
    {
        return this;
    }

    auto ref point()
    {
        return this;
    }

    auto ref line( W w, H h )
    {
        return this;
    }


    auto to(T:File)( string filename )
    {
        auto f = File( filename, "w" );
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
    OX ox;
}

struct Line
{
    OP type = OP.LINE;
    OX ox;
}
