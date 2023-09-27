module vf.platform.windows.game;

// Linux
//   pool <- evdev <- device 
//     D( time, type, code, value )
//        M32   M16   M16   M32
// my version
//        M32   M16   M16   M64
//        R64               R64  // on x86_64
//        R32   R32         R32  // on x86
//
// Windows
//   pool <- GetMessage <- device 
//     D( hwnd, message, wParam, lParam, time, pt,  lPrivate )
//        M64   M32      M64     M64     M32   M128 M32  // on x86_64
//        M32   M32      M32     M32     M32   M128 M32  // on x86
// my version
//              M64      M64     M64     M64  // 64
//              R64      R64     R64     R64
//              M32      M32     M32     M32  // 32
//              R32      R32     R32     R32

// OS
// pool
// sensors
// go
//   for d in pool
//     for s in sensors
//       s( d )

version(WINDOWS_NATIVE):
import std.container.dlist : DList;
import std.stdio : writeln;
import std.functional : toDelegate;
import core.sys.windows.windows;
import vf;

struct Game
{
    static
    Pool    pool;
    //Sensors sensors;
    int     result;

    //
    void go()
    {
        import core.runtime;

        try
        {
            Runtime.initialize();

            auto window = new DLWindow();
            
            foreach( e; pool )
            {
                TranslateMessage( &e );
                DispatchMessage( &e );
                //sensors.sense( e );
            }

            Runtime.terminate();
        }
        catch (Throwable o)
        {
            import std.string;
            import std.utf;
            MessageBox( NULL, o.toString.toUTF16z, "Error", MB_OK | MB_ICONEXCLAMATION );
        }
    }
}


class DLWindow : Window
{
    import core.sys.windows.windows;

    override
    void event( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
    {
        writeln( message );
    }
}


//
void init_windows_native()
{
    //
}



//
static
this()
{
    init_windows_native();
}

