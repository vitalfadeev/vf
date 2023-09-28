module vf.platform.windows.ui.window;

version(WINDOWS_NATIVE):
import core.sys.windows.windows;
import vf.types;


class Window
{
    HWND hwnd;

    alias T = typeof(this);


    this( PX size=PX(640,480), string name="Windows Window" )
    {
        _create_window( size, name );
        _create_renderer();
    }

    //
    LRESULT event( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
    {
        return DefWindowProc( hwnd, message, wParam, lParam );
    }

    // private
    private
    void _create_window( PX size, string name )
    {
        import std.utf : toUTF16z;
        import std.traits;

        HINSTANCE hInstance = GetModuleHandle(NULL);
        int       iCmdShow  = 1;
        
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
        ShowWindow( hwnd, iCmdShow );
        UpdateWindow( hwnd ); 
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
                if ( _vf_windows.length == 1 )
                    return _vf_windows[0].event( hwnd, message, wParam, lParam );
                else
                {
                    import std.algorithm.searching : countUntil;
                    auto i = _os_windows.countUntil( hwnd );
                    if ( i != -1 )
                    {
                        if ( message == WM_DESTROY )
                        {
                            auto ret = _vf_windows[i].event( hwnd, message, wParam, lParam );
                            unregister( hwnd );
                            return ret;
                        }
                        else
                        {
                            return _vf_windows[i].event( hwnd, message, wParam, lParam );
                        }
                    }
                }
            } 
            catch (Throwable o) { o.show_throwable; }

            return DefWindowProc( hwnd, message, wParam, lParam );
        }
    }
}


struct Drawer
{
    HDC hdc;

    void line()
    {
        //
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


void CaptureScreen()
{
    int     screen_width   = GetSystemMetrics( SM_CXSCREEN );
    int     screen_height  = GetSystemMetrics( SM_CYSCREEN );
    HWND    desktop_wnd    = GetDesktopWindow();
    HDC     desktop_dc     = GetDC( desktop_wnd );
    HDC     capture_dc     = CreateCompatibleDC( desktop_dc );
    HBITMAP capture_bitmap = CreateCompatibleBitmap( desktop_dc, screen_width, screen_height );
    SelectObject( capture_dc, capture_bitmap ); 

    BitBlt( capture_dc, 0, 0, screen_width, screen_height, desktop_dc, 0,0, SRCCOPY|CAPTUREBLT );

    BITMAPINFO bmi;
    bmi.bmiHeader.biSize        = bmi.bmiHeader.sizeof;
    bmi.bmiHeader.biWidth       = screen_width;
    bmi.bmiHeader.biHeight      = screen_height;
    bmi.bmiHeader.biPlanes      = 1;
    bmi.bmiHeader.biBitCount    = 32;
    bmi.bmiHeader.biCompression = BI_RGB;

    auto pixels = new RGBQUAD[ screen_width * screen_height ];

    GetDIBits(
        capture_dc, 
        capture_bitmap, 
        0,  
        screen_height,  
        pixels.ptr, 
        &bmi,  
        DIB_RGB_COLORS
    );  

    // pPixels
    // ...

    pixels.destroy();

    ReleaseDC( desktop_wnd, desktop_dc );
    DeleteDC( capture_dc );
    DeleteObject( capture_bitmap );
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
                    return __traits(getMember, This, m)( hwnd, message, wParam, lParam ); 

    return DefWindowProc( hwnd, message, wParam, lParam );
}
