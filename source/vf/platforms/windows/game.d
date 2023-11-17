module vf.platforms.windows.game;

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

// Game
//   queue
//   world
//   go
//     for e in queue
//       world.sense(e)

// Sensor
//   on_key_press
//     > E.click ( dst=this, type=click )
//   on_click
//     > E.app_cmd_play ( dst=app, type=app_cmd_play )
//     do ...

// World
//   semse
//     ? dst is null
//       sense_all
//         foreach s in sensors
//           s.sense()
//     :
//       sense_one
//         s = find dst in sensors
//           s.sense()

// Button
//   text = "new text"
//   |
//   V
// Render_Tree
//   button
//     rect
//     |
//     V
// < DRAW rect
//   |
// > DRAW rect
//   Render_Tree
//     find rect
//       find objects
//         each draw
//     update Render_Tree
//     rasterize rect


version(WINDOWS):
import core.sys.windows.windows;
public import vf.base.game;
import vf.interfaces     : IWindow;
import vf.interfaces     : ISensAble;
import vf.queue          : Queue;
import vf.world          : World;
import vf.window         : Window;
import vf.window_manager : WindowManager;
import vf.event          : Event, EventType;


class Game : vf.base.game.Game!(Queue,Event,EventType)
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

    IWindow new_window()
    {
        return WindowManager.instance.new_window!Window();
    }

    override
    void quit( int quit_code=0 )
    {   
        PostQuitMessage( quit_code );
    }


    //
    void delegate_sense( Event* event, EventType event_type )
    {
        import std.stdio : writeln;
        writeln( "sense: ", *event, "; ", event_type );
    }
}

