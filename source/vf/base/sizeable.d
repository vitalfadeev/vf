module vf.base.sizeable;

import std.typecons     : Tuple;
import vf.base.drawable : DrawAble;


class SizeAble(La,LaType,WX) : DrawAble!(La,LaType,WX)
{
    alias THIS      = typeof(this);
    alias SizeAble  = typeof(this);
    alias SIZE_MODE = .SIZE_MODE;

    Size      _size;
    SIZE_MODE size_mode = SIZE_MODE.FIXED;

    void calc_size()
    {
        _size = Size( ops.calc_size() );
    }

    ref Size size()
    {
        return _size;
    }

    override
    void redraw()
    {
        //send_la( VF_REDRAW, this.size );
    }

    override
    bool hit_test( WX wx )
    {
        import std.stdio : writeln;
        writeln( "wx in size: ", wx, " in ", (size + this.wx) );
        return ( wx in (size + this.wx) );
    }

    //
    struct Size
    {
        WX a;
        WX b;

        this( Tuple!(WX, "a", WX, "b") t )
        {
            a = t.a;
            b = t.b;
        }

        this( WX a, WX b )
        {
            this.a = a;
            this.b = b;
        }

        void grow( Size other )
        {
            // min
            if ( other.a.x < a.x  )
                a.x = other.a.x;

            if ( other.a.y < a.y )
                a.y = other.a.y;

            // max
            if ( other.b.x > b.x  )
                b.x = other.b.x;

            if ( other.b.y > b.y )
                b.y = other.b.y;
        }

         auto opBinaryRight( string op : "in" )( WX wx )
         {
            return (
                a.x <= wx.x && a.y <= wx.y &&
                b.x >= wx.x && b.y >= wx.y
            );
         }

         typeof(this) opBinary( string op : "+" )( WX wx )
         {
            return typeof(this)( a+wx, b+wx );
         }
    }
}

//
void update_sizes(La,LaType,WX)( LayoutAble!(La,LaType,WX) e )
{
    e.each_recursive( &e.calc_size );
}

enum SIZE_MODE
{
    OUTER = 1,
    FIXED = 2,
    INTER = 3,
}

