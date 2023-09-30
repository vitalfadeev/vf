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
    OX ox;
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

