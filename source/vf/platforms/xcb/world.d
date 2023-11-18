module vf.platforms.xcb.world;

version(XCB):
import xcb.xcb;
import vf.base.world          : BaseWorld;
import vf.platforms.xcb.event : Event, EventType;
import vf.platforms.xcb.wx    : WX;


class World : BaseWorld!(Event,EventType,WX)
{    
    alias THIS = typeof(this);

    void sense( Event* event, EventType event_type, WX src_world_offset )
    {
        //
    }

    override
    void sense( Event* event, EventType event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        event.world = this;
        super.sense( event, event_type );
    }

    auto select_at( WX wx )
    {
        if ( hit_test( wx ) )
            return this;

        return null;
    }

    void on_XCB_EVENT_MASK_BUTTON_PRESS( Event* event, EventType event_type )
    {
        auto element = 
            select_at( 
                SX( 
                    event.button_press.event_x,
                    event.button_press.event_y
                )
                    .to_wx 
                    + event.world_offset           //
            );                                     // 
                                                   // event.to_wx 
                                                   //   devide.to_wx 
                                                   //   src.to_wx 
        
        //import std.stdio : writeln;
        //writeln( element );
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

