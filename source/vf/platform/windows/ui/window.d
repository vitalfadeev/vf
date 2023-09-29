module vf.platform.windows.ui.window;

version(WINDOWS_NATIVE):
import core.sys.windows.windows;
import vf.types;
import vf.raster;


class Window
{
    HWND hwnd;

    alias T = typeof(this);


    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( cmd_show, size, name );
        _create_renderer();
    }

    //
    LRESULT event( UINT message, WPARAM wParam, LPARAM lParam ) 
    {
        return DefWindowProc( hwnd, message, wParam, lParam );
    }

    // private
    private
    void _create_window( int cmd_show, PX size, string name )
    {
        import std.utf : toUTF16z;
        import std.traits;

        HINSTANCE hInstance = GetModuleHandle(NULL);
        
        auto className = toUTF16z( fullyQualifiedName!(typeof(this)) );
        WNDCLASS wndClass;

        // Create Window Class
        wndClass.style         = CS_HREDRAW | CS_VREDRAW;
        wndClass.lpfnWndProc   = &WindowManager.event;
        wndClass.cbClsExtra    = 0;
        wndClass.cbWndExtra    = 0;
        wndClass.hInstance     = hInstance;
        wndClass.hIcon         = LoadIcon( null, IDI_EXCLAMATION );
        wndClass.hCursor       = LoadCursor( null, IDC_CROSS );
        wndClass.hbrBackground = GetStockObject( DKGRAY_BRUSH );
        wndClass.lpszMenuName  = null;
        wndClass.lpszClassName = className;

        // Register class
        if ( !RegisterClass( &wndClass ) ) 
            throw new WindowsException( "Unable to register class" );

        // Create Window
        hwnd = CreateWindow(
            className,            //Window class used.
            name.toUTF16z,        //Window caption.
            WS_OVERLAPPEDWINDOW,  //Window style.
            CW_USEDEFAULT,        //Initial x position.
            CW_USEDEFAULT,        //Initial y position.
            size.x,               //Initial x size.
            size.y,               //Initial y size.
            null,                 //Parent window handle.
            null,                 //Window menu handle.
            hInstance,            //Program instance handle.
            null                  //Creation parameters.
        );                           

        if ( hwnd == NULL )
            throw new WindowsException( "Unable to create window"  );

        // Link HWND -> Window
        WindowManager.register( hwnd, this );

        // Show
        if ( cmd_show )
        {
            ShowWindow( hwnd, cmd_show );
            UpdateWindow( hwnd ); 
        }
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

    static
    struct WindowManager
    {
        static HWND[] _os_windows;
        static T[]    _vf_windows;

        static
        T vf_window( HWND hwnd )
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

        extern( Windows ) static nothrow
        LRESULT event( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
        {
            try {
                import std.algorithm.searching : countUntil;
                auto i = _os_windows.countUntil( hwnd );
                if ( i != -1 )
                {
                    if ( message == WM_DESTROY )
                    {
                        auto ret = _vf_windows[i].event( message, wParam, lParam );
                        unregister( hwnd );
                        return ret;
                    }
                    else
                    {
                        return _vf_windows[i].event( message, wParam, lParam );
                    }
                }
            } 
            catch (Throwable o) { o.show_throwable; }

            return DefWindowProc( hwnd, message, wParam, lParam );
        }
    }

    Raster to(T:Raster)( HDC hdc )
    {
        RECT rect;
        int  window_width;
        int  window_height;
        int  client_width;
        int  client_height;
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
            Raster(
                /*pixels*/  pixels,
                /*w*/       client_width.to!W,
                /*h*/       client_height.to!H,
                /*pitch*/   window_width * RGBQUAD.sizeof,
                /*current*/ pixels.ptr,
                /*color*/   RGBQUAD(0,0,255,255)
                );

    }
}


nothrow
void show_throwable( Throwable o )
{
    import std.string;
    import std.utf;
    try { auto s = o.toString.toUTF16z; 
        MessageBox( NULL, s, "Error", MB_OK | MB_ICONEXCLAMATION );
    }
    catch (Throwable o) { MessageBox( NULL, "Window: o.toString error", "Error", MB_OK | MB_ICONEXCLAMATION ); }
}


LRESULT auto_route_event(T)( T This, HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
{
    import std.traits;
    import std.string;
    import std.format;

    // on_
    static foreach( m; __traits( allMembers, T ) )
        static if ( isCallable!(__traits(getMember, T, m)) )
            static if ( m.startsWith( "on_" ) )
                if ( message == mixin( m[3..$] ) )
                    return __traits(getMember, This, m)( message, wParam, lParam ); 

    return DefWindowProc( hwnd, message, wParam, lParam );
}
