module vf.platforms.xcb.world;

version(XCB):
import xcb.xcb;
import vf.base.fixed            : Fixed;
import vf.base.world            : BaseWorld;
import vf.platforms.xcb.la   : La, LaType;
import vf.platforms.xcb.wx      : WX;
import vf.platforms.xcb.element : Element;


class World : BaseWorld!(La,LaType,WX)
{    
    alias THIS = typeof(this);

    override
    void sense( La* la, LaType la_type )
    //      this       la             la_type
    //      RDI        RSI               RDX
    {
        la.world = this;

        if ( la_type == XCB_EVENT_MASK_BUTTON_PRESS )
            on_XCB_EVENT_MASK_BUTTON_PRESS( la, la_type );

        super.sense( la, la_type );
    }

    void on_XCB_EVENT_MASK_BUTTON_PRESS( La* la, LaType la_type )
    {
        WX _wx = WX( Fixed(la.button_press.la_x,0),
                     Fixed(la.button_press.la_y,0)
                ) + la.world_offset;

        la.button_press_wx = _wx;

        super.on_XCB_EVENT_MASK_BUTTON_PRESS( la, la_type );
    }

    // lazy World iterator
    import std.range;
    //struct Range(T,FUNC)
    //{
    //    FUNC element_checker; // bool function( T a )
    //    T cur;
    //    bool empty()     pure nothrow @nogc { return _a >= _b || _arr.length < _b; }
    //    char front()     pure nothrow @nogc { return cur; }
    //    void popFront()  pure nothrow @nogc { a++; }
    //    T    moveFront() pure nothrow @nogc { return _arr.moveAt(_a); }
    //    void opBinary( string op : "~" )( T b )       { _arr ~ b; }
    //    void opBinary( string op : "~" )( Range!T b ) { _arr ~ b.array; }
    //}
}


class LaRouter
{
    World world;

    void sense( La* la, LaType la_type )
    //      this       la             la_type
    //      RDI        RSI               RDX
    {
        switch ( la_type )
        {
            case XCB_EVENT_MASK_BUTTON_PRESS: on_XCB_EVENT_MASK_BUTTON_PRESS( la, la_type ); break;
            default:
                world.sense( la, la_type );
        }
    }

    void on_XCB_EVENT_MASK_BUTTON_PRESS( La* la, LaType la_type )
    {
        auto element = find_element( la, world );
        if ( element !is null )
            element.sense( la, la_type );
    }    

    Element find_element( La* la, Element root )
    {
        foreach( ref e; root.enter )
        {
            if ( hit_test( la.button_press_wx ) )
            {
                auto deep_e = find_element( la, e );
                if ( deep_e !is null )
                    return deep_e;
                else
                    return e;
            }
        }

        return null;
    }
}

import vf.platforms.xcb.window : Window;

class MouseDevice
{
    alias SX = Window.PX;
}
alias SX = MouseDevice.SX;

WX to_wx( SX sx ) 
{
    return WX( sx.x, sx.y );
}


