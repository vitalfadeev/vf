import std.stdio;
import vf;
import vf.base.fixed : Fixed;

//version=READ;
//version=WRITE;

void main()
{
    import core.runtime : Runtime;

    try {
        Runtime.initialize();

    	MyGame.instance.go();

        Runtime.terminate();
    }
    catch ( Throwable o ) { 
        import vf.exception : show_throwable;
        o.show_throwable; 
    }
}


class MyGame : Game
{
	alias THIS = typeof(this);

    this()
    {        
        import vf.button : Button;
        world.enter.put( new Button() );
    }

	override
    Window new_window()
    {
        return new MyWindow( world );
    }

    // for able 
    //   MyGame().go() 
    //   MyGame().quit()
    static
    typeof(this) instance()
    {
        static typeof(this) _instance;
        
        if ( _instance is null )
            _instance = new typeof(this);

        return _instance;
    }
}


class WorldWindow(World,Event,EventType) : Window
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
    void sense( Event* event, EventType event_type )
    //      this       event             event_type
    //      RDI        RSI               RDX
    {
        event.world_offset = world_offset;
        super.sense( event, event_type );
        //world.sense( event, event_type, world_offset );
    }


    override
    void draw( Event* event, EventType event_type ) 
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

class MyWindow : WorldWindow!(World,Event,EventType)
{
    this(ARGS...)( World world, ARGS args )
    {
    	super( world, args );
    }

    class FocusManager
    {
        //
    }

    //override
    //void sense( Event* event, EventType event_type ) 
    //{
    //    auto_route_event!( this, event, event_type );
    //}

    // Linux
    //version(XCB)
    //override
    //void on_XCB_EXPOSE( Event* event, EventType event_type ) 
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
    ERESULT on_WM_PAINT( Event* event, EventType event_type ) 
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
    void on_WM_LBUTTONDOWN( Event* event, EventType event_type )
    {
    	MessageBox( NULL, "on_WM_LBUTTONDOWN", "info", MB_OK | MB_ICONEXCLAMATION );
    }

    version(WINDOWS)
    void on_WM_DESTROY( Event* event, EventType event_type )
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
//   case event_type == e
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
// InputEventType  input_event_type  BUTTON_PRESSED
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
