module vf.gline;

// G graphics line
// drawable
//  wx
//   go, point, line
//     add operation, points   // go, point, line
//     zoom
//     rotate
//     brush                   // new lines, remove control line
//     ...detalization         // 1 point -> 2 point, 2 lines smooth -> 3 lines. curve -> multi lines
// sizeable
//  wx
//   -x,-y,+x,+y = calc_size
// layoutable
//  wx
//   calc_pos
//     x,y = pos
//   in_rect
//     select o where o in rect
// rasterable
//  px
//   rasterize
//     wx -> px
//     crop                    // crop = clip
//     color                   // 
//     mix bg fg               //
//     pixels                  //

version = DEFAULT;

import vf.wx : WX;
import vf.px : PX;



struct Drawable
{
    Op[] ops;

    void point( WX wx ) { ops ~= Op( Point( wx ) ); }
    void line ( WX wx ) { ops ~= Op( Line ( wx ) ); }
}

struct Layoutable
{
    PX xy; 
    PX wh;

    void go()
    {
        //get_sizes();
        //in_rect( xy, wh );
    }

    void get_sizes(R)( R range )
    {
        foreach ( ref o; range )
            o.get_size();  // child.get_size( parent )
    }

    void in_rect( PX xy, PX wh )
    {
        //
    }
}

struct Rasterable
{
    void point( PX px ) {}
    void line ( PX px ) {}
}

version(XCB)
template XCBRasterable()
{
    import xcb.xcb;

    // XCB vars
    xcb_connection_t* c;
    uint8_t           coordinate_mode = XCB_COORD_MODE_PREVIOUS;  // XCB_COORD_MODE_ORIGIN, XCB_COORD_MODE_PREVIOUS
    xcb_drawable_t    drawable;
    xcb_gcontext_t    gc;

    uint32_t     points_len;
    xcb_point_t* points;

    //auto _c         = this.c;
    //auto _mode      = this.coordinate_mode;
    //auto _drawable  = this.drawable;
    //auto _gc        = this.gc;

    // xcb_point_t
    //    int16_t x
    //    int16_t y

    //
    void point( PX px ) { xcb_poly_point( c, mode, drawable, gc, points_len, points ); }
    void line ( PX px ) { xcb_poly_line(  c, mode, drawable, gc, points_len, points ); }
}


struct Gline(DRAWABLE,LAYOUTABLE,RASTERABLE)
{
    DRAWABLE   draw_able;
    LAYOUTABLE layout_able;
    RASTERABLE raster_able;
    PX[2]      clip;

    void go()
    {
        layout_able.go();
        clipped!()._go();
    }

    // private:
    void _go()
    {
        foreach ( ref op; draw_able.ops )
            switch ( op.type )
            {
                case POINT : _point( op ); break;
                case LINE  : _line ( op ); break;
                default:
            }
    }

    // CLIP
    template clipped()
    {
        void _go()
        {
            foreach ( ref op; draw_able.ops )
                switch ( op.type )
                {
                    case POINT : _point( op ); break;
                    case LINE  : _line ( op ); break;
                    default:
                }
        }

        pragma( inline, true )
        void _point( ref Op op )
        {
            raster_able.point( op.point.wx.to_px );
        }

        pragma( inline, true )
        void _line( ref Op op )
        {
            raster_able.line( op.line.wx.to_px );
        }
    }

    //
    pragma( inline, true )
    void _point( ref Op op )
    {
        raster_able.point( op.point.wx.to_px );
    }

    pragma( inline, true )
    void _line( ref Op op )
    {
        raster_able.line( op.line.wx.to_px );
    }
}

struct Point
{
    int type;
    WX  wx;

    this( WX wx )
    {
        this.wx = wx; 
    }
}

struct Line
{
    int type;
    WX  wx;

    this( WX wx )
    {
        this.wx = wx; 
    }
}

union Op
{
    int   type;
    Point point;
    Line  line;

    this( Point b )
    {
        point = b;
    }

    this( Line b )
    {
        line = b;
    }
}



PX to_px( WX wx )
{
    version(DEFAULT)
        return PX( wx.x & 0xFFFF0000 >> 16, wx.y & 0xFFFF0000 >> 16 );
    version(VECTOR)
        return PX( wx.x & 0xFFFF0000      | wx.y & 0xFFFF0000 >> 16 );
}

