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
	MyGame().go();
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
    LRESULT event( Event e, EventCode code, EventValue value )
    {
        return auto_route_event( this, e, code, value );
    }

    LRESULT on_WM_PAINT( Event e, EventCode code, EventValue value )
    {
    	version(WINDOWS_NATIVE)
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
	    }

        return 0;
    }

    LRESULT on_WM_LBUTTONDOWN( Event e, EventCode code, EventValue value )
    {
    	MessageBox( NULL, "on_WM_LBUTTONDOWN", "info", MB_OK | MB_ICONEXCLAMATION );
        return 0;
    }

    LRESULT on_WM_DESTROY( Event e, EventCode code, EventValue value )
    {
        MyGame().quit();

        return 0;
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
