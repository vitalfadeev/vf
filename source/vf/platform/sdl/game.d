module vf.platform.sdl.game;

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
import queue : Queue;
import vf.sensor;
import vf.types;
import vf.cls.o : IVAble, ILaAble, ISenseAble, IStateAble;
public import vf.ui.window;

Game game;  // for each CPU core
            //   queue 1 for all CPU cores

struct Game
{
    static
    Queue    queue;
    Sensors sensors;

    //
    void go()
    {
        foreach( d; queue )
            sensors.sense( d );
    }
}


struct Sensors
{
    SENSOR[] sensors;
    alias sensors this;

    void sense( D d )  // 2 argumnts: ( t, m ):       ( CPU reg1, CPU reg2 )
    {                  //   + this  : ( this, t, m ): ( CPU reg1, CPU reg2, CPU reg3 )
        foreach( s; sensors )
            s( d );
    }

    void opOpAssign( string op : "~" )( SENSOR b )
    {
        this.sensors ~= b;
    }

    void opOpAssign( string op : "~" )( SENSORF b )
    {
        this.sensors ~= toDelegate( b );
    }

    void opOpAssign( string op : "~" )( ISenseAble b )
    {
        this.sensors ~= &(b.sense);
    }
}




unittest
{
    // function
    // sensor, no-brain, action
    void KeyASensor( D d )
    {
        if ( d.t == DT_KEY_PRESSED )               // sensor
        if ( d.m == cast(MPTR)'A' )                //
            game.queue ~= DT_KEY_A_PRESSED;         // action
    }

    // struct.function
    // sensor, no-brain, action
    struct KeyCTRLSensor
    {
        static
        void sense( D d )
        {
            if ( d.t == DT_KEY_PRESSED )           // sensor
            if ( d.m == cast(MPTR)'!' )            // 
                game.queue ~= DT_KEY_CTRL_PRESSED;  // action
        }
    }

    // class
    // sensor, brain, action
    class KeysCTRLASensor : ISenseAble
    {
        bool ctrl;                                 // brain memory
        bool a;

        //
        void sense( D d )
        {
            switch ( d.t )                         // sensor
            {
                case DT_KEY_CTRL_PRESSED: on_KEY_CTRL_PRESSED( d ); break;
                case DT_KEY_A_PRESSED:    on_KEY_A_PRESSED( d ); break;
                default: return;
            }

            //
            if ( ctrl && a )                          // brain login
                game.queue ~= DT_KEYS_CTRL_A_PRESSED;  // action

            // ANY CODE
            //   check d.m
            //   queue ~= d(sid,m)
            //   direct action
        }


        pragma( inline, true )
        void on_KEY_CTRL_PRESSED( D d )
        {
            ctrl = true;                                     // action
        }

        pragma( inline, true )
        void on_KEY_A_PRESSED( D d )
        {
            a = true;                                        // action
        }
    }

    //
    game.sensors ~= &KeyASensor;           // func
    game.sensors ~= &KeyCTRLSensor.sense;  // struct 
    game.sensors ~= new KeysCTRLASensor(); // class
    game.sensors ~= function ( D d ) { import std.stdio; writeln( "Lambda Sensor: ", d ); };

    //// SDL require Window for events
    //import ui.window : WindowSensor;
    //auto window_sensor = new WindowSensor();

    //
    game.queue ~= D_KEY_PRESSED( '!' );
    game.queue ~= D_KEY_PRESSED( 'A' );

    ////
    //game.go();
    //
    //
    //assert( game.queue.empty );
    //assert( a.length == 5 );
    //assert( a == [
    //        D(DT.KEY_PRESSED, cast(MPTR)'!'), 
    //        D(DT.KEY_PRESSED, cast(MPTR)'A'), 
    //        D(DT.KEY_CTRL_PRESSED, null), 
    //        D(DT.KEY_A_PRESSED, null), 
    //        D(DT.KEYS_CTRL_A_PRESSED, null)
    //    ] );
}


unittest
{
    void ClipboardCopy()
    {
        // direct
        // via queue
    }
}


//abstract
//class OClass : SensorClass
//{
//    alias T = typeof(this);

//    DList!T v;
//}


// game.go
pragma( inline, true )
void go()
{
    .game.go();
}

// game.sensors
pragma( inline, true )
ref auto sensors()
{
    return .game.sensors;
}

// game.queue
pragma( inline, true )
ref auto queue()
{
    return .game.queue;
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


void send_la( PX xy )
{
    auto d = xy.to!D;  // rect.xy_
    d.t = DT_LA;
    game.queue ~= d;
}

void send_la( PXPX xyxy )
{
    auto d = xyxy.to!D;  // rect.xy_
    d.t = DT_LA;
    game.queue ~= d;
}


//
static
this()
{
    init_sdl();

    // PS
    // on Windows SDL Window must be created for using event loop
    //   because events going from window &WindowProc
}

