module vf.platforms.xcb.game;

// Linux
//   queue <- evdev <- device 
//     D( time, type, code, value )
//        M32   M16   M16   M32
// my version
//        M32   M16   M16   M64
//        R64               R64  // on x86_64
//        R32   R32         R32  // on x86
//
// Windows
//   queue <- GetMessage <- device 
//     D( hwnd, message, wParam, lParam, time, pt,  lPrivate )
//        M64   M32      M64     M64     M32   M128 M32  // on x86_64
//        M32   M32      M32     M32     M32   M128 M32  // on x86
// my version
//              M64      M64     M64     M64  // 64
//              R64      R64     R64     R64
//              M32      M32     M32     M32  // 32
//              R32      R32     R32     R32

// OS
// queue
// sensors
// go
//   for d in queue
//     for s in sensors
//       s( d )

version(XCB):
import xcb.xcb;
public import vf.base.game;
import vf.interfaces     : IWindow;
import vf.queue          : Queue;
import vf.world          : World;
import vf.window         : Window;
import vf.window_manager : window_manager;
import vf.event          : Event, EVENT_TYPE;


class Game : vf.base.game.Game!(Queue,Event,EVENT_TYPE)
{
    World world = new World();
    
    //
    override
    void go()
    {
        auto window = new_window();

        sensors ~= &delegate_sense;
        sensors ~= &window_manager.sense;
        sensors ~= &world.sense;

        super.go();
    }

    IWindow new_window()
    {
        return window_manager.new_window!Window();
    }

    override 
    void quit( int quit_code=0 )
    {   
        //
    }


    //
    void delegate_sense( Event* event, EVENT_TYPE event_type )
    {
        import std.stdio : writeln;
        writeln( "sense: ", *event );
    }
}
