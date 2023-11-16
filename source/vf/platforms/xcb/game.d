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
import vf.base.game                    : BaseGame;
import vf.platforms.xcb.world          : World;
import vf.platforms.xcb.queue          : Queue;
import vf.platforms.xcb.window         : Window;
import vf.platforms.xcb.window_manager : WindowManager;
import vf.platforms.xcb.event          : Event, EVENT_TYPE;


class WindowedGame(Window) : BaseGame!(Queue,Event,EVENT_TYPE)
{
    Window window;

    override
    void go()
    {
        window = new Window();

        sensors ~= &WindowManager.instance.sense;

        super.go();
    }
}

class WorldGame(World) : BaseGame!(Queue,Event,EVENT_TYPE)
{
    World world = new World();

    override
    void go()
    {
        sensors ~= &world.sense;
        super.go();
    }
}

class Game : BaseGame!(Queue,Event,EVENT_TYPE)
{
    World world = new World();
    
    //
    override
    void go()
    {
        auto window = new_window();

        sensors ~= &delegate_sense;
        sensors ~= &WindowManager.instance.sense;
        sensors ~= &world.sense;

        super.go();
    }

    Window new_window()
    {
        return new Window();
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
