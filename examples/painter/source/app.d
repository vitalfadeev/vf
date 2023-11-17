import std.stdio;
import vf;

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
	alias T = typeof(this);

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

    this(ARGS...)( World world, ARGS args )
    {
        super( args );
        this.world = world;
        move_to_center();
        show();
    }

    override
    void draw( Event* event, EventType event_type ) 
    {
        import vf.base.rasterizer  : BaseRasterizer;
        import vf.platforms.xcb.wx : WX;
        world.draw();  // ops ~= Line()
        world.to_raster( cast(BaseRasterizer!WX)rasterizer );  // ops -> window
    }
}


class MyWindow : WorldWindow!(World,Event,EventType)
{
    this(ARGS...)( World world, ARGS args )
    {
    	super( world, args );
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
