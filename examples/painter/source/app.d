import std.stdio;
import vf;
import vf.base.fixed   : Fixed;
import vf.base.timeval : Timeval;
import vf.base.focus_manager : FocusManager;

//version=READ;
//version=WRITE;
LaType;
EV_WINDOW_ACTIVATED;
EV_WINDOW_DEACTIVATED;
la;

void 
main () {
    import core.runtime : Runtime;

    try {
        Runtime.initialize();
        scope (exit) Runtime.terminate();

        alias Window = BaseWindow!LaType;

        alias WindowFocusManager = 
            FocusManager!(
                Window,
                LaType,
                EV_WINDOW_ACTIVATED,
                EV_WINDOW_DEACTIVATED,
                ()=>(la.window)
            );
        WindowFocusManager wfm;

        alias World = BaseWorld;
        World world;

        alias la_switch = 
            LaSwitch!(
                LaType,
                    EV_REL, 
                    EV_BTN, 
                    EV_KEY, 
                    EV_APP_WINDOW_ACTIVATED,
                    EV_APP_ELEMENT_SET_FOCUS,
                    EV_APP_ELEMENT_AUT_FOCUS,
                    EV_APP_QUIT,
                        &wfm.sense,
                    EV_APP_WORLD_REL, 
                    EV_APP_WORLD_BTN, 
                        &world.sense,
            );  // provides delegate: sense (la_type)

        void 
        delegate_sense (LaType la_type) {
            writeln ("delegate_sense: ", la_type);
        }


        alias Sensors = AliasSeq!( 
            &delegate_sense,
            &Struct().sense,
            &la_switch.sense  // --> window, --> world
        );

    	BaseGame !(Queue,Sensors)
            .go;
    }

    catch ( Throwable o ) { 
        import vf.exception : show_throwable;
        o.show_throwable; 
    }
}

struct 
Struct  {
    void 
    sense (LaType la_type) {
        writeln ("Delegater.sense: ", la_type);
    }
}


class MyGame : Game
{
	alias THIS = typeof (this);

    this () {        
        import vf.button : Button;
        world.enter.put( new Button() );
    }

	override Window 
    new_window () {
        return new MyWindow( world );
    }

    // for able 
    //   MyGame().go() 
    //   MyGame().quit()
    static typeof(this) 
    instance () {
        static typeof(this) _instance;
        
        if ( _instance is null )
            _instance = new typeof(this);

        return _instance;
    }
}


class WorldWindow(World,Event,LaType) : Window
{
    World world;
    WX    world_offset = WX( Fixed(-320,0), Fixed(-240,0) );

    this(ARGS...)( World world, ARGS args )
    {
        super( args );
        this.world = world;
        move_to_center();
        show();
    }

    override
    void sense( Event* event, LaType la_type )
    //      this       event             la_type
    //      RDI        RSI               RDX
    {
        event.world_offset = world_offset;
        super.sense( event, la_type );
        //world.sense( event, la_type, world_offset );
    }


    override
    void draw( Event* event, LaType la_type ) 
    {
        GLine( world, rasterizer );
    }
}

pragma( inline, true )
void GLine(World,Rasterizer)( World world, Rasterizer rasterizer )
{
    with ( world ) {
        draw();      // ops ~= Line()
        transform(); // ops.apply( matrix )
        calc_size(); // size = calc_size()
        layout();    // pos   // now Button at 0,0 always, World offset is 320,240
        to_raster( rasterizer );  // ops -> window        
        // rasterizer( world, window );
    }
}

class MyWindow : WorldWindow!(World,Event,LaType)
{
    this(ARGS...)( World world, ARGS args )
    {
    	super( world, args );
    }

    //override
    //void sense( Event* event, LaType la_type ) 
    //{
    //    auto_route_event!( this, event, la_type );
    //}

    // Linux
    //version(XCB)
    //override
    //void on_XCB_EXPOSE( Event* event, LaType la_type ) 
    //{
        // world
        //   get all draws
        //   raster
        //world.to_raster( rasterizer );



       // import xcb.xcb;
       // import vf.platform            : platform;
       // import vf.platforms.xcb.types : uint32_t;

       // auto expose = event.expose;
       // auto c      = platform.c;

       // //
       ///* geometric objects */
       // xcb_point_t[] points = [
       //     {10, 10},
       //     {10, 20},
       //     {20, 10},
       //     {20, 20}
       // ];

       // xcb_point_t[] polyline = [
       //     {50, 10},
       //     { 5, 20},     /* rest of points are relative */
       //     {25,-20},
       //     {10, 10}
       // ];

       // /* Create black (foreground) graphic context */
       // xcb_gcontext_t foreground = xcb_generate_id( c );
       // uint32_t       value_mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
       // uint32_t[]     value_list = [ platform.screen.white_pixel, 0 ];

       // xcb_create_gc( c, foreground, hwnd, value_mask, value_list.ptr );

       // //
       // xcb_poly_point( c, XCB_COORD_MODE_ORIGIN,   hwnd, foreground, 4, points.ptr );
       // xcb_poly_line(  c, XCB_COORD_MODE_PREVIOUS, hwnd, foreground, 4, polyline.ptr );

       // xcb_flush( c );
       // import std.stdio : writeln;
       // writeln( __FUNCTION__  );



        /*
        HDC         hdc;
        PAINTSTRUCT ps; 
        hdc = BeginPaint( hwnd, &ps );

        xcb_gcontext_t foreground;
        foreground = xcb_generate_id( c );

        // geometric objects
        xcb_point_t[4] points = [
            {10, 10},
            {10, 20},
            {20, 10},
            {20, 20}
        ];
        xcb_poly_point( c, XCB_COORD_MODE_ORIGIN, win, foreground, points.length, points.ptr );

        this
            .to_painter()               // window  -> painter  (get pixels)
              .go_center()
              .go( 0, +10 )
              .line( +5,0 )
              .tee
                .to_file( "savegame.sg" )
            .to_raster( this, this.c )  // painter -> raster   (rasterize)
            .to_window( this );         // raster  -> window   (put pixels)

        EndPaint( hwnd, &ps );

        return ERESULT.init;
        */
    //}


    // Windows
	version(WINDOWS_NATIVE)
    ERESULT on_WM_PAINT( Event* event, LaType la_type ) 
    {
        try {
            HDC         hdc;
            PAINTSTRUCT ps; 
            hdc = BeginPaint( hwnd, &ps );
            //RECT        crect;
            //GetClientRect( hwnd, &crect );

            //version(READ)
            //{
            //import std.stdio : File;
            //File("savegame.sg")
            //    .to_painter()
            //    .to_raster( this, hdc )
            //    .to_window( this, hdc );
            //}
            version(WRITE)
            {
            import std.stdio : File;
	        this.to_painter( hdc )
	        	// WH
	        	//.go_center()
                //.line(  +10,-10  )
	        	//.line(  +40, 0   )
	        	//.line(  +50,+50  )
	        	//.line(    0,+50  )
	        	//.line( -100,+100 )
	        	//.line( -100,-100 )
	        	//.line(    0,-50  )
	        	//.line(  +50,-50  )
	        	//.line(   40, 0   )
	        	//.line(  +10,+10  )

	        	//.go( 0,-100 )
	        	//.line( +203,+10  )
	        	//.line( -203,+10  )
	        	//.line( -203,-10  )
	        	//.line( +203,-10  )

	        	//.go( 0,-90  )
	        	//.line( +10,+103 )
	        	//.line( -10,+103 )
	        	//.line( -10,-103 )
	        	//.line( +10,-103 )

                .go_center()
                .go( 0, +10 )
                .line( +5,0 )

                //.line( +8,+5 )  // 8/5 = 5 items by 1 px  + 1 item by 3 px
                //.line( +8,+3 )
                //.line( -8,-3 )
                //.line( +8,-3 )

                //.go( 0, +10 )
                //.line( +3,+3 )
                //.line( -3,+3 )
                //.line( -3,-3 )
                //.line( +3,-3 )

                //.go( 0, +10 )
                //.line( +2,+2 )
                //.line( -2,+2 )
                //.line( -2,-2 )
                //.line( +2,-2 )

                .tee
                    .to_file( "savegame.sg" )
                .to_raster( this, hdc )
                .to_window( this, hdc );
            }

            EndPaint( hwnd, &ps ) ;
        } 
        catch (Throwable o) { o.show_throwable; }

        return 0;
    }

    version(WINDOWS)
    void on_WM_LBUTTONDOWN( Event* event, LaType la_type )
    {
    	MessageBox( NULL, "on_WM_LBUTTONDOWN", "info", MB_OK | MB_ICONEXCLAMATION );
    }

    version(WINDOWS)
    void on_WM_DESTROY( Event* event, LaType la_type )
    {
        MyGame.instance.quit();
    }
}


auto tee(T)( T This )
{
    struct _Tee
    {
        T _this;

        T to_file(ARGS...)( ARGS args )
        {
            .to_file( _this, args );
            return _this;
        }
    }
    return _Tee( This );
}


// screen
// ---------------------------------------
// 
// 
// 
// 
// 
// 
// ---------------|     |-----------------  
//              1 |  2  | 3                 // selector
// ---------------|     |-----------------
// ====================================|==  // queue

// World
//  e class state     // add element
//  e 0x01 0b00000001 // add element 0x01 0b00000001
//
//  e class state     // add element
//   a text "OK"      // set attribute "text" == "OK"
//
//  e class state     // add element
//  enter             //
//   e class state    // add child element
//  ret               //
//
//  s                 // select 
//   c class Button   //   condition class == Button
//
//  s                  // select 
//   c and             //   condition and
//   c   class Button  //   condition class == Button
//   c   state hover   //   condition state == hover
//
// selection           // selection
//  a text "OK"        //  set each atte text == "OK"

// World
//  e class state     // add element
// 
// World
//  sense
//   case la_type == e
//    enter ~= new class_state()

// Colors
//  1 Dominant     // lightest <-
//  2 SubDominant  //            |
//  3 Third        // +1         |
//  4 Neitral      //  0         |
//  5 Disabled     // -1         |
//  6 Shadow       //            |
//  7 Background   // darkest    |
//                               |
// Button                        |
//   draw                        |
//     color 1  -----------------

// Fonts
//  1 Button Text
//  2 
//  3
//  4 
//  5 Window Title

// Sizes
//  1 200x100  Button size
//  2
//  3
//  4
//  5


// void button_clicked(GtkWidget *button, gpointer data)
// void a_callback_function(GtkWidget *widget, gpointer user_data);
// signal( Source, Event )
//
// Source
//   signal() -> ( Source, Event )  ---
//                                     |
// Element                             |
//   sense()  <- ( Source, Event )  <--
//     signal
//   signal() -> ( Element, Event )
//
// SignalAble
//   signal()
// SenseAble
//   sense()
// Element : SenseAble, SignalAble
//
// Evdev : SignalAble
//   signal()
// Udev : SignalAble
//   signal()
// Dbus : SignalAble
//   signal()
// Xcb : SignalAble
//   signal()
// Vf : SignalAble
//   signal()
//
// QueueSource
//   Queue
//   foreach ( e; queue )
//     Queue.signal( QueueSource, e )
//
// EvdevSource
//   Queue
//   foreach ( e; queue )
//     Queue.signal( QueueSource, e )
//
// KeyboardSource : DevSource
//   Evdev
//     Queue
//
// DevSource  // /dev/input/eventX
//   Evdev
//     Queue
//   cap_abilities

// connect( src, signal_name, dst,   callback, data )
// connect( src, signal_name, null,  callback, data )
// connect( src, signal_name, delegate       , data )
// connect( src, signal_name, data1, callback, data )
// 
//  call
//    callback( dst, data )
//    callback( data1, ... )
//

// InputDevice
// InputDriver
// InputEvent
// 
// InputDevice     input_device      Mouse
// InputDriver     input_driver      Evdev
// InputEvent      input_event       
// InputEvent      input_event       ButtonInputEvent
// InputLaType  input_la_type  BUTTON_PRESSED
// ...                               data
//
// ElementEvent    element_event
// ...                               element

// MouseDeviceSource
//   signal
//   click -> 
//     ClickManager  (World,Window) SX->WX
//       find_element
//         send Event

// HardKey -> Evdev -> PointerDevice
//
// HardKey -> Evdev -> KeyboardDevice
//  
// HardKey -> Evdev -> VolumeControllerDevice
//

// HardKey -> Evdev -> PointerDevice -> MouseCursor -> Event
//                                      MouseButton
//                                      MouseWheel

// Event
//  source : Device, Vf
//    type = DEVICE
//    device : Cursor, Keyboad
//      type = MOUSE
//      mouse
//        type = MOVE
//        relXY
//        ...

// Event
//  source : Device, Vf
//    type = DEVICE
//    device : Cursor, Keyboad
//      type = KEYBOARD
//      keyboard
//        type = KEY_PRESSED
//        scancode
//        ...

// Event
//  source : Device, Vf
//    type = VF
//    vf
//      element

// hard_device -> evdev -> /dev/input/eventX -> open,poll,read -> event
//
// HardDevice
//   driver
//     evdev
//       file = "/dev/input/eventX"
//   
// hard_device.connect( "button_pressed", click_manager )
// hard_device.connect( button.pressed, click_manager )
// click_manager.sense( event )

// CursorMover
//   sense
//     MouseEvent
//     KeyEvent
//     ApiEvent
//   connect
//     to MouseSource
//     to KeySource
//     to ApiSource


struct CursorMover
{
    void sense( Event* event )
    {
        //
    }

    void _connections()
    {
        MouseSource.connect( this );
        KeySource.connect( this );
        ApiSource.connect( this );
    }
}

class Source
{
    void connect( SenseAble senseable )
    {
        //
    }

    void send( Event* event )
    {
        foreach ( senseable; senseables )
            senseable.sense( event );

        // or 

        Queue.put( this, event, sensable );
    }
}

class MouseSource : Source
{
    override
    void connect( SenseAble senseable )
    {
        //
    }

    override
    void send( Event* event )
    {
        foreach ( senseable; senseables )
            senseable.sense( event );

        // or 

        Queue.put( this, event, sensable );
    }
}

class SourceManager : Source
{
    MouseSource _mouse_source;
    KeySource _keyboard_sourec;

    override
    void connect( SenseAble senseable )
    {
        //
    }

    override
    void send( Event* event )
    {
        foreach ( senseable; senseables )
            senseable.sense( event );

        // or 

        Queue.put( this, event, sensable );
    }
}


// MouseManager
//   MouseDevice
//   MouseDevice

// Device
// MouseDevice
// EvdevMouseDevice
//
// class Device 
// class MouseDevice : Device 
// class EvdevMouseDevice : MouseDevice
//
// MouseDevice.connect( this )
// MouseDevice.connect( click, this )
//
// MouseDeviceManager
// MouseDeviceManager.connect( this )
// MouseDeviceManager.connect( click, this )

// ConnectAble
//   connect()
//   send()

// SenseAble
//   sense()

// SendAble
//   send()

// predefined paged dynamic array
//   ppda arr
// class
//   PPDA(T,N,N2)
//     page1
//       size_t      length
//       T[N]        items
//       Page!(T,N2) next
//  ForEach
//    2 methods:
//      1: 1 page
//        if page1.next is null
//           foreach ( e; page1.items )
//             ...
//      2: N pages
//        page = &page1
//        while ( 1 )
//           foreach ( e; page.items )
//             ...
//           if page.next
//             page = page.next
//             continue
//           else
//             break

// Connect vs Filter
// World
//   Queue.filter_for_me( this, Filter )
//   same as
//   this
//     sense()
//       Filter()
// 
// signal
//   send
//   no call..return 

// Source
//   slot clicked          // caps
//   slot button_pressed   //
//   slot button_released  //
// EV_KEY, EV_REL, EV_ABS, EV_MSC, EV_SW, EV_LED, EV_SND, EV_REP, EV_FF, EV_PWR, EV_FF_STATUS

// Source
//   slot key_pressed   //
//   slot key_released  //

// WindowSource 
//   slot activated     //
//   slot deactivated   //
//   slot moved         //
//   slot resized       //
//   slot paint         //

//                                          Router
// evdev                -|- queue by time -  Source 
// Windows.GetMessage() -|                    slot - processor
// vf                   -|                    slot
//                                            slot

// Router
//   Source
//     slot - processor,processor,...
//   Source
//     slot

// Router
//   Source
//     slot.connect( processor ) 

// Router
//   Key
//     pressed
//     released
//   Mouse
//     moved
//     pressed
//     released
//     wheel
//   Window
//     activated
//     deactivated

// World
//  sense( Event* )


// SIGNAL
// signaler
//   signal - subscribers
//   signal - subscribers

// element
//   send
//   signal
//
// dbus
//   send
//   signal
//   connect( subscriber, signals[] )
//
// evdev
//   send
//   signal
//
// vf
//   send
//   signal

// dbus.connect( element, [mounted,unmounted] )

// APP_QUEUE
// EVDEV_QUEUE
// TIMER_QUEUE
// DBUS_QUEUE
//
// APP_QUEUE
//  APP_ELEMENT_UPDATED, APP_ELEMENT_UPDATED
// EVDEV_QUEUE
//  EV_KEY, EV_KEY
// TIMER_QUEUE
//  TIMER_EV, TIMER_EV  // timestamp, timestamp
// DBUS_QUEUE
//  DBUS_UDISKS2_NEW_DISK, DBUS_UDISKS2_REMOVE_DISK
// 
// timestamp
//   secons (from 1970/01/01) +
//   micro_secons (1/1_000_000 sec)

alias Timestamp = Timeval;

// recursive to non-recutsive
// stack  -> PTR[] stack
// func( root ) -> func( root, &stack )..while..loop

//var stack = [];
//stack.push(firstObject);
//// while not empty
//while (stack.length) {
//    // Pop off end of stack.
//    obj = stack.pop();
//    // Do stuff.
//    // Push other objects on the stack as needed.
//    ...
//}

// find deepest iterated
E find_deepest(E,TEST)( E e, TEST test )
  if ( is( TEST : bool function(E) ) )
{
    E tested_deepest_e;

    loop:
    foreach ( e2; e.enter )
    if ( test( e2 ) ) {
        tested_deepest_e = e2;
        e = e2;
        goto loop;
    }

    return tested_deepest_e;
}

// Button Play
//   get from audio-player
//   move by mouse into desktop
//   press on button - play in audio-player
//
// save with button
//   instance id
//   player start command line + dir + env / .desktop-file / .lnk
//   button id
//   app-play-event emited by button
//
// when press button
//   send app-play-event in instance id
//   if instance id not exists
//      start  player
//      send app-play-event in instance

// Timer Queue
//   min_timeval
//   timers[]
//     timer1: id, timeval, interval
//     timer2: id, timeval, interval
//     timer3: id, timeval, interval
//
// queue
//   app
//   evdev
//   dbus
//   timers
//
//   poll
//     evdev
//       /dev/input/eventX
//     dbus
//       DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

// KEY MODIFIER
// space + key = modified key
// space        = space
//
// GAME MODE KEYS
// left hand:
//     w   - cursor move
//   a s d -
//
//   small 3     ukaz
//   fingr fingr fingr
//   ----- ----- ----- -------------
//   ~     1 2 3 4
//   tab   q . e r
//   caps  . . . f
//   shift z x c v
//   ----- ----- -------------------
//             |       space       |
//   -------------------------------
//                    big fingr
// 
//   big finger
//   ----------
//   space + key = modified key
//   space       = space
// 
// right hand:

//   mouse

//
// GAME
//
// -----
// evdev --
// -----   \   Event                            -------------              ------------                  -------
//           - switch                           WindowManager              FocusManager                  Element
//               EV_KEY --------------------> active       ------------> focused     ----------------> sense                              --------
//                                         -> set_active    |         -> change_focused             -> set_focus -> EV_ELEMENT_FOCUSED -> AppQueue
// ---                                   /      |           |       /      ------------           /      -------                          --------
// xcb  -------- EV_WINDOW_ACTIVATED ---        |           |      /                             /
// ---                                          |           |     /                             /
//             - EV_ELEMENT_FOCUSED  ----------------------------                              /
// --------   /                                 |           |                                 /
// AppQueue -                                   |           |         ----------------       /
// --------                                     |           |         ElementManager        /
//               EV_BTN (left) -------------> active       -------> find_element_at_xy  ---
//                                              |           |         |              |
//                                              |           |         |              |
//                                              |           |         |              |
//                                              |           |         |              |
//               EV_REL --------------------> active       -------> 
//                                              -------------         ----------------
//    
//                                                                     ----------------
//                                                                     HoverManager  
//                                                                    in
//                                                                    over
//                                                                    out
//                                                                     ----------------


// EVT_BTN
//   window
//     clickcy -> world.xy
//     emit WOLRD_CLICK_XY
//
// WOLRD_CLICK_XY
//   world
//     ...
