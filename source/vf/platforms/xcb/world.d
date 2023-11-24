module vf.platforms.xcb.world;

version(XCB):
import xcb.xcb;
import vf.base.fixed            : Fixed;
import vf.base.world            : BaseWorld;
import vf.platforms.xcb.event   : Event, EventType;
import vf.platforms.xcb.wx      : WX;
import vf.platforms.xcb.element : Element;


class World : BaseWorld!(Event,EventType,WX)
{    
    alias THIS = typeof(this);

    override
    void sense( Event* event, EventType event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        event.world = this;

        if ( event_type == XCB_EVENT_MASK_BUTTON_PRESS )
            on_XCB_EVENT_MASK_BUTTON_PRESS( event, event_type );

        super.sense( event, event_type );
    }

    void on_XCB_EVENT_MASK_BUTTON_PRESS( Event* event, EventType event_type )
    {
        WX _wx = WX( Fixed(event.button_press.event_x,0),
                     Fixed(event.button_press.event_y,0)
                ) + event.world_offset;

        event.button_press_wx = _wx;

        super.on_XCB_EVENT_MASK_BUTTON_PRESS( event, event_type );
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


class EventRouter
{
    World world;

    void sense( Event* event, EventType event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        switch ( event_type )
        {
            case XCB_EVENT_MASK_BUTTON_PRESS: on_XCB_EVENT_MASK_BUTTON_PRESS( event, event_type ); break;
            default:
                world.sense( event, event_type );
        }
    }

    void on_XCB_EVENT_MASK_BUTTON_PRESS( Event* event, EventType event_type )
    {
        auto element = find_element( event, world );
        if ( element !is null )
            element.sense( event, event_type );
    }    

    Element find_element( Event* event, Element root )
    {
        foreach( ref e; root.enter )
        {
            if ( hit_test( event.button_press_wx ) )
            {
                auto deep_e = find_element( event, e );
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


