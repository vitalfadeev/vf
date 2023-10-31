module vf.draw;

import vf.interfaces : IDrawAble;
import vf.platform   : M16, OX, PX;


class Draw : IDrawAble
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

    //auto ref point()
    //{
    //    ops ~= Point();
    //    return this;
    //}

    auto ref line( W w, H h )
    {
        ops ~= Line( OP.LINE, OX( w,h ) );
        return this;
    }

    //
    void point( int x, int y )
    {
        //
    }
}

//
import vf;

version(LINUX_X11)
auto to_painter(WINDOW)( WINDOW window )
{
    return new Painter();
}

version(LINUX_X11)
auto to_painter(WINDOW)( WINDOW window )
{
    return new Painter();
}
version(LINUX_X11)
auto to_raster(WINDOW:Window)( Painter painter, WINDOW window )
{
    // window -> raster
    auto raster = to_raster( window );

    foreach( op; painter.ops )
    {
        final
        switch ( op.type )
        {
            case OP._         : break;
            case OP.GO_CENTER : raster.go_center(); break;
            case OP.GO        : raster.go( op.go.ox.to_px ); break;
            case OP.POINT     : raster.point() ; break;
            case OP.POINTS    : break;
            case OP.POINTS    : break;
            case OP.LINE      : raster.line( op.line.ox.to_px ); break;
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

    return raster;
}


version(WINDOWS)
auto to_painter(WINDOW)( WINDOW window, HDC hdc )
{
    return new Painter();
}

version(WINDOWS)
import vf;
version(WINDOWS)
auto to_raster(WINDOW:Window)( Painter painter, WINDOW window, HDC hdc )
{
    // rasterize
    auto raster = vf.window.to_raster( window, hdc );

    foreach( op; painter.ops )
    {
        final
        switch ( op.type )
        {
            case OP._         : break;
            case OP.GO_CENTER : raster.go_center(); break;
            case OP.GO        : raster.go( op.go.ox.to_px ); break;
            case OP.POINT     : raster.point() ; break;
            case OP.POINTS    : break;
            case OP.POINTS    : break;
            case OP.LINE      : raster.line( op.line.ox.to_px ); break;
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

    return raster;
}

// file save / read
import std.stdio : File;
version(stub)
auto to_file( Painter painter, string filename )
{
    // header
    //   SG version
    // operations
    //   type
    //   args

    auto f = File( filename, "w" );

    // header
    SGFile_Header header;
    f.rawWrite( ( cast(ubyte*)&header )[0..header.sizeof] );

    // operations
    foreach ( op; painter.ops )
        f.rawWrite( ( cast(ubyte*)&op )[0..Op.sizeof] );

    return f;
}


import std.stdio : File;
version(stub)
auto to_painter( File f )
{
    // header
    SGFile_Header header;
    auto head_readed = f.rawRead( (cast(ubyte*)&header)[0..header.sizeof] );

    // Painter
    auto painter = new Painter();

    // operations
    Op op;

    while ( true )
    {
        auto op_readed = f.rawRead( (cast(ubyte*)&op)[0..op.sizeof] );
        
        if ( op_readed.length < op.sizeof )
            break;

        painter.ops ~= op;
    }

    return painter;
}


struct SGFile_Header
{
    M8[4]               magic = [ 'S', 'G', '0', '1' ];
    M16                 header_size;
    SGFile_Operation[0] operations;
}


struct SGFile_Operation
{
    //
}



//
enum OP : M16  // 16-bit because AH:GROUP, AL:ACTION
{
    _         = 0b00000000_00000000,
    GO_CENTER = 0b00000001_00000001,
    GO        = 0b00000001_00000010,
    POINT     = 0b00000010_00000001,
    POINTS    = 0b00000010_00000010,
    POINTAT   = 0b00000010_00000100,
    LINE      = 0b00000100_00000001,
    LINES     = 0b00000100_00000010,
    TRIANGLE  = 0b00001000_00000001,
    TRIANGLES = 0b00001000_00000010,
    QUAD      = 0b00010000_00000001,
    QUADS     = 0b00010000_00000010,
    CIRCLE    = 0b00100000_00000001,
    CIRCLES   = 0b00100000_00000010,
    ARC       = 0b01000000_00000001,
    ARCS      = 0b01000000_00000010,
}


struct Op
{
    union 
    {
        OP       type;
        GoCenter go_center;
        Go       go;
        Point    point;
        PointAt  point_at;
        Points   points;
        Line     line;
        Lines    lines;
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

struct PointAt
{
    OP type = OP.POINTAT;
    OX ox;
}

struct Points
{
    OP   type = OP.POINTS;
    OX[] oxs;
}

struct Line
{
    OP type = OP.LINE;
    OX ox;
}

struct Lines
{
    OP   type = OP.LINES;
    OX[] oxs;
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


// object
//   drawable
//     button
//
// drawable
//   point
//   points
//   line
//   lines
//
// object
//   clickable
//     button
//
// clickable
//   click
//
// interface clickable
//   click
//   on_click
//   event( ClickEvent* )
//   event( Event* )
// 
// enum Events
//   click

IDrawAble draw;

static
this()
{
    draw = new Draw();
}
