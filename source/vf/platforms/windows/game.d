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

// OS
// queue
// sensors
// go
//   for d in queue
//     for s in sensors
//       s( d )

version(WINDOWS):
import core.sys.windows.windows;
public import vf.base.game;
import vf.interfaces     : IWindow;
import vf.queue          : Queue;
import vf.sensors        : Sensors;
import vf.window         : Window;
import vf.window_manager : window_manager;


class Game : vf.base.game.Game
{
    Sensors sensors;
    Queue   queue;
    int     result;

    //
    override
    void go()
    {
        auto window = new_window();
        sensors ~= window_manager;

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


