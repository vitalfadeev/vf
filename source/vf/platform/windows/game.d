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

version(WINDOWS_NATIVE):
import std.container.dlist : DList;
import std.stdio : writeln;
import std.functional : toDelegate;
import core.sys.windows.windows;
import vf;

class Game
{
    static
    Queue   queue;
    //Sensors sensors;
    int     result;

    //
    void go()
    {
        import core.runtime;

        try
        {
            Runtime.initialize();

            auto window = new_window();

            foreach( ref e; queue )
            {
                TranslateMessage( &e );
                DispatchMessage( &e );
                //sensors.sense( e );
            }

            Runtime.terminate();
        }
        catch (Throwable o) { o.show_throwable; }
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
