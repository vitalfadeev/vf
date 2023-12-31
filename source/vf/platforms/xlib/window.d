module vf.platforms.linux.window_xlib;

version(LINUX_X11):
import xcb.xcb;  // x11.xcb
import vf.types;


class Window
{
    Window   x_mainwindow;
    Display* x_display;
    Screen   x_screen;

    alias THIS = typeof(this);


    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( size, name,cmd_show );
        _create_renderer();
    }

    //
    LRESULT la( La e, LaCode code, LaValue value ) 
    {
        return DefWindowProc( hwnd, cast(UINT)e, cast(WPARAM)code, cast(LPARAM)value );
    }

    // private
    private
    void _create_window( PX size, string name, int cmd_show )
    {
        char*                displayname = null;
        XSetWindowAttributes attribs;
        XGCValues            xgcvalues;

        x_display = XOpenDisplay( displayname );
        if ( !x_display )
        {
            import std.format;

            if ( displayname )
                throw new LinuxX11Exception( format!"Could not open display [%s]"( displayname ) );
            else
                throw new LinuxX11Exception( format!"Could not open display (DISPLAY=[%s])"( getenv("DISPLAY") ) );
        }

        x_screen = DefaultScreen( x_display );

        x_width  = SCREENWIDTH;
        x_height = SCREENHEIGHT;

        x_cmap = 
            XCreateColormap( 
                x_display, 
                RootWindow( x_display, x_screen ), 
                x_visual, 
                AllocAll );

        attribmask = CWLaMask | CWColormap | CWBorderPixel;

        attribs.la_mask =
            KeyPressMask
            | KeyReleaseMask
            // | PointerMotionMask | ButtonPressMask | ButtonReleaseMask
            | ExposureMask;

        attribs.colormap = X_cmap;
        attribs.border_pixel = 0;

        x_mainwindow = 
            XCreateWindow(   
                x_display,
                RootWindow( x_display, x_screen ),
                size.x, size.y,
                x_width, x_height,
                0, // borderwidth
                8, // depth
                InputOutput,
                x_visual,
                attribmask,
                &attribs );

        // create the GC
        valuemask = GCGraphicsExposures;
        xgcvalues.graphics_exposures = False;

        x_gc = 
            XCreateGC(   
                x_display,
                x_mainwindow,
                valuemask,
                &xgcvalues );

        XMapWindow( x_display, x_mainwindow );

        
    }


    auto ref move_to_center()
    {
        RECT rect;
        GetWindowRect( hwnd, &rect );

        auto ws = GetSystemMetrics( SM_CXSCREEN );
        auto hs = GetSystemMetrics( SM_CYSCREEN );

        SetWindowPos(
          hwnd,
          null,
          (ws - (rect.right - rect.left))/2,
          (hs - (rect.bottom - rect.top))/2,
          0,
          0,
          SWP_NOSIZE | SWP_NOZORDER | SWP_ASYNCWINDOWPOS
        );

        return this;
    }


    auto ref show()
    {
        ShowWindow( hwnd, 1 );
        UpdateWindow( hwnd ); 

        return this;
    }


    private
    void _create_renderer()
    {
        //
    }


    // hwnd -> window
    // window -> hwnd
    static
    struct WindowManager
    {
        static HWND[] _os_windows;
        static THIS[]    _vf_windows;

        static
        THIS vf_window( HWND hwnd )
        {
            import std.algorithm.searching : countUntil;
            auto i = _os_windows.countUntil( hwnd );

            return _vf_windows[i];
        }

        static 
        void register( HWND hwnd, Window _this )
        {
            _os_windows ~= hwnd;
            _vf_windows ~= _this;
        }

        static nothrow
        void unregister( HWND hwnd )
        {
            import std.algorithm.searching : countUntil;
            import std.algorithm.mutation : remove;
            auto i = _os_windows.countUntil( hwnd );
            _os_windows = _os_windows.remove( i );
            _vf_windows = _vf_windows.remove( i );
        }

        extern( Windows ) 
        static nothrow
        LRESULT la( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
        {   //              RCX,       RDX,            R8,            R9
            // Microsoft x64 calling convention:
            //   RCX, RDX, R8, R9
            try {
                import std.algorithm.searching : countUntil;
                auto i = _os_windows.countUntil( hwnd );
                if ( i != -1 )
                {
                    if ( message == WM_DESTROY )
                    {
                        auto ret = _vf_windows[i].la( La(message), LaCode(wParam), LaValue(lParam) );
                        unregister( hwnd );
                        return ret;
                    }
                    else
                    {
                        return _vf_windows[i].la( La(message), LaCode(wParam), LaValue(lParam) );
                    }
                }
            } 
            catch (Throwable o) { o.show_throwable; }

            return DefWindowProc( hwnd, message, wParam, lParam );
        }
    }
}


LRESULT auto_route_la(THIS)( THIS This, La e, LaCode code, LaValue value )
{
    import std.traits;
    import std.string;
    import std.format;

    // on_
    static foreach( m; __traits( allMembers, THIS ) )
        static if ( isCallable!(__traits(getMember, THIS, m)) )
            static if ( m.startsWith( "on_" ) )
                if ( e == mixin( m[3..$] ) )
                    return __traits(getMember, This, m)( e, code, value ); 

    return DefWindowProc( This.hwnd, cast(UINT)e, code, value );
}


import vf.raster;
Raster to_raster( Window This, HDC hdc )
{
    RECT rect;
    int  window_width;
    int  window_height;
    int  client_width;
    int  client_height;
    
    auto hwnd = This.hwnd;

    if ( GetWindowRect( hwnd, &rect ) )
    {
        window_width  = rect.right - rect.left;
        window_height = rect.bottom - rect.top;

        GetClientRect( hwnd, &rect );
        client_width  = rect.right - rect.left;
        client_height = rect.bottom - rect.top;
    }
    else
    {
        throw new WindowsException( "GetWindowRect: " );
    }

    //HDC hdc = GetDC( hwnd );

    HDC     capture_dc     = CreateCompatibleDC( hdc );
    HBITMAP capture_bitmap = CreateCompatibleBitmap( hdc, window_width, window_height );
    SelectObject( capture_dc, capture_bitmap ); 

    BitBlt( capture_dc, 0, 0, window_width, window_height, hdc, 0,0, SRCCOPY|CAPTUREBLT );

    BITMAPINFO bmi;
    with ( bmi.bmiHeader )
    {        
        biSize          = bmi.bmiHeader.sizeof;
        biWidth         = window_width;
        biHeight        = -window_height;
        biPlanes        = 1;
        biBitCount      = RGBQUAD.sizeof * 8;
        biCompression   = BI_RGB;
        biSizeImage     = window_width * window_height * cast(uint)RGBQUAD.sizeof;
        //biXPelsPerMeter = 72;
        //biYPelsPerMeter = 72;
        biClrUsed       = 0;
        biClrImportant  = 0;
    }

    auto pixels = new RGBQUAD[ window_width * window_height ];

    GetDIBits(
        hdc, 
        capture_bitmap, 
        0,  
        window_height,
        pixels.ptr, 
        &bmi,  
        DIB_RGB_COLORS
    );  

    // pixels in this.pixels

    //ReleaseDC( hwnd, hdc );
    DeleteDC( capture_dc );
    DeleteObject( capture_bitmap );

    import std.conv : to;
    return
        new Raster(
            /*pixels*/  pixels,
            /*w*/       client_width.to!W,
            /*h*/       client_height.to!H,
            /*pitch*/   window_width * RGBQUAD.sizeof,
            /*current*/ pixels.ptr,
            /*color*/   RGBQUAD(0,0,255,255)
            );

}
