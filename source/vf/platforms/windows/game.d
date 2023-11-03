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
import vf.window_manager : window_manager;
import vf.event          : Event, EVENT_TYPE;
import vf.types          : SENSOR;

class Game : vf.base.game.Game
{
    World   world = new World();
    Sensors sensors;
    Queue   queue;
    int     result;

    //
    override
    void go()
    {
        auto window = new_window();

        sensors ~= window_manager;
        sensors ~= world;

        // event_instance, event_type, event_args...
        foreach( ref event; queue )
            sensors.sense( &event, event.type );
    }

    IWindow new_window()
    {
        return window_manager.new_window!Window();
    }

    override
    void quit( int quit_code=0 )
    {   
        PostQuitMessage( quit_code );
    }
}


struct Sensors
{
    ISensAble[] _sensors;
    alias _sensors this;

    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach( sensor; _sensors )
            sensor.sense( event, event_type );
    }
}
