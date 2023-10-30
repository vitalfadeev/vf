import std.stdio;

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

// G pipeline
//   goes, points, lines
//     add operations, points  // go, point, line
//     zoom
//     rotate
//     brush                   // new lines, remove control line
//     ...detalization         // 1 point -> 2 point, 2 lines smooth -> 3 lines
//     crop                    // crop = clip
//   rasterize
//     ox -> px
//     color                   // 
//     mix bg fg               //
//     pixels                  //

import vf;

//version=READ;
version=WRITE;


void main()
{
    import core.runtime : Runtime;
    import vf : show_throwable;

    try
    {
        Runtime.initialize();

    	MyGame().go();

        Runtime.terminate();
    }
    catch ( Throwable o ) { o.show_throwable; }
}



class MyGame : Game
{
	alias T = typeof(this);

	override
    Window new_window()
    {
        return new MyWindow();
    }

    // for able 
    //   MyGame().go() 
    //   MyGame().quit()
    static
    T opCall()
    {
        static 
        T _instance;

        if ( _instance is null )
            _instance = new T();

        return _instance;
    }
}


class MyWindow : Window
{
    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
    	super( size, name, 0 );
        move_to_center();
        show();
    }

    override
    void sense( Event* event, EVENT_TYPE event_type ) 
    {
        auto_route_event( this, event, event_type );
    }

    // Linux
    version(XCB)
    void on_XCB_EXPOSE( Event* event, EVENT_TYPE event_type ) 
    {
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
    }


    // Windows
	version(WINDOWS_NATIVE)
    ERESULT on_WM_PAINT( Event* event, EVENT_TYPE event_type ) 
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
    void on_WM_LBUTTONDOWN( Event* event, EVENT_TYPE event_type )
    {
    	MessageBox( NULL, "on_WM_LBUTTONDOWN", "info", MB_OK | MB_ICONEXCLAMATION );
    }

    version(WINDOWS)
    void on_WM_DESTROY( Event* event, EVENT_TYPE event_type )
    {
        Game.quit();
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
