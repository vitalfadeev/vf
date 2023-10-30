module vf.platform.windows.game;

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
import vf.sensors;
import vf.queue;
import vf.ui.window;


class Game
{
    Sensors sensors;
    Queue   queue;
    int     result;

    //
    void go()
    {
        auto window = new_window();

        foreach( ref event; queue )
            sensors.sense( &event, event.type );
    }

    Window new_window()
    {
        return new Window();            
    }

    static
    void quit( int quit_code=0 )
    {   
        PostQuitMessage( quit_code );
    }
}


