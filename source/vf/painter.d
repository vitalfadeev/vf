module vf.painter;

import std.stdio;
import vf.types;


class Painter
{
    Op[] ops;

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
    GO,
    POINT,
    LINE,
}


struct Op
{
    union 
    {
        OP      type;
        PointOp point;
    }
}

struct GoOp
{
    OP type = OP.GO;
    OX ox;
}

struct PointOp
{
    OP type = OP.POINT;
    OX ox;
}

struct LineOp
{
    OP type = OP.LINE;
    OX ox;
}
