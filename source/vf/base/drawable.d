module vf.base.drawable;

import vf.base.sensable : Sensable;
import vf.base.types    : M16;


class DrawAble(Event,EVENT_TYPE,WX) : Sensable!(Event,EVENT_TYPE)
{
    Ops!WX ops;

    void point( int x, int y )
    {
        ops ~= Op!WX( PointAt!WX( WX( x, y ) ) );
    }
}


// IDrawAble
//struct DrawAble
//{
//    Ops ops;

    //auto ref go_center()
    //{
    //    ops ~= GoCenter();
    //    return this;
    //}

    //auto ref go( W w, H h )
    //{
    //    ops ~= Go( OP.GO, WX( w, h ) );
    //    return this;
    //}

    ////auto ref point()
    ////{
    ////    ops ~= Point();
    ////    return this;
    ////}

    //auto ref line( W w, H h )
    //{
    //    ops ~= Line( OP.LINE, WX( w,h ) );
    //    return this;
    //}

//    //
//    void point( int x, int y )
//    {
//        ops ~= Op( PointAt( OP.POINTAT, WX( cast(X)x, cast(Y)y ) ) );
//    }
//}

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
            case OP.GO        : raster.go( op.go.wx.to_px ); break;
            case OP.POINT     : raster.point() ; break;
            case OP.POINTS    : break;
            case OP.POINTS    : break;
            case OP.LINE      : raster.line( op.line.wx.to_px ); break;
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


struct Op(WX)
{
    union 
    {
        OP          type;
        GoCenter    go_center;
        Go!WX       go;
        Point!WX    point;
        PointAt!WX  point_at;
        Points!WX   points;
        Line!WX     line;
        Lines!WX    lines;
    }

    this( Point!WX b )
    {
        point = b;
    }

    this( PointAt!WX b )
    {
        point_at = b;
    }

    WX calc_wh();
    void apply( M matrix );
    auto max_x()
    {
        final
        switch ( type )
        {
            case OP._         : break;
            case OP.GO_CENTER : break;
            case OP.GO        : break;
            case OP.POINT     : break;
            case OP.POINTAT   : break;
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

        return typeof(WX.x)();
    }
    auto max_y()
    {
        final
        switch ( type )
        {
            case OP._         : break;
            case OP.GO_CENTER : break;
            case OP.GO        : break;
            case OP.POINT     : break;
            case OP.POINTAT   : break;
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

        return typeof(WX.x)();
    }
}

struct M
{

}

struct GoCenter
{
    OP type = OP.GO_CENTER;
}


struct Go(WX)
{
    OP type = OP.GO;
    WX wx;
}

struct Point(WX)
{
    OP type = OP.POINT;
}

struct PointAt(WX)
{
    OP type = OP.POINTAT;
    WX wx;

    this( WX wx )
    {
        this.wx = wx;
    }
}

struct Points(WX)
{
    OP   type = OP.POINTS;
    WX[] wxs;
}

struct Line(WX)
{
    OP type = OP.LINE;
    WX wx;
}

struct Lines(WX)
{
    OP   type = OP.LINES;
    WX[] wxs;
}


//
struct Ops(WX)
{
    Op!WX[] arr;
    alias arr this;

    void opOpAssign(string op:"~", T)( T b )
        if ( 
            is( T == GoCenter ) || 
            is( T == Go!WX ) || 
            is( T == Point!WX ) || 
            is( T == Line!WX )
        )
    {
        arr ~= Op(b);
    }

    auto calc_wh()
    {
        import std.typecons : tuple;

        typeof(WX.x) max_x;
        typeof(WX.y) max_y;

        foreach ( ref op; arr )
        {
            UPD_MAX( op.max_x, max_x );
            UPD_MAX( op.max_y, max_y );
        }

        return tuple!("x","y")( max_x, max_y );
    }    

    void apply(M)( M matrix )
    {
        foreach ( ref op; arr )
            op.apply( matrix );
    }
}


void UPD_MAX(T)( T a, ref T b )
{
    if ( a > b )
        b = a;
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

