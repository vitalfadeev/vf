module vf.platforms.sdl.game;

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

version(SDL):
import std.container.dlist : DList;
import std.stdio : writeln;
import std.functional : toDelegate;
import bindbc.sdl;
import vf.queue : Queue;
import vf.types;
public import vf.window;


class Game
{
    static
    Queue   queue;
    int     result;

    //
    void go()
    {
        auto window = new_window();

        foreach( e; queue )
        {
            window.la( La(e) );
        }
    }

    Window new_window()
    {
        return new Window();            
    }

    static
    void quit( int quit_code=0 )
    {   
        SDL_QuitLa e;
        SDL_PushLa( cast(SDL_La*)&e );
    }
}


//
void init_sdl()
{
    SDLSupport ret = loadSDL();

    if ( ret != sdlSupport ) 
    {
        if ( ret == SDLSupport.noLibrary ) 
            throw new Exception( "The SDL shared library failed to load" );
        else 
        if ( ret == SDLSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_204, GLFW_2010 etc.)" );
    }

    loadSDL( "sdl2.dll" );
}


//
static
this()
{
    init_sdl();

    // PS
    // on Windows SDL Window must be created for using la loop
    //   because las going from window &WindowProc
}

