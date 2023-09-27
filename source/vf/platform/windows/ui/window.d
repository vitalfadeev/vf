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
    void event( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
    {
        //
    }

    // private
    private
    void _create_window( PX size, string name )
    {
        import std.utf : toUTF16z;

        HINSTANCE hInstance = GetModuleHandle(NULL);
        int       iCmdShow  = 1;
        
        auto className = toUTF16z( "vfwindow" );
        WNDCLASS wndClass;

        // Create Window Class
        wndClass.style         = CS_HREDRAW | CS_VREDRAW;
        wndClass.lpfnWndProc   = &WindowProc;
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
            throw new WindowsException( "Unable to register class"  );

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

        static nothrow
        void event( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
        {
            try {
                import std.algorithm.searching : countUntil;
                auto i = _os_windows.countUntil( hwnd );
                if ( i != -1 )
                    _vf_windows[i].event( hwnd, message, wParam, lParam );
            } catch (Throwable o) {
                import std.string;
                import std.utf;
                try { auto s = o.toString.toUTF16z; 
                    MessageBox( NULL, s, "Error", MB_OK | MB_ICONEXCLAMATION );
                }
                catch (Throwable o) { MessageBox( NULL, "Window: o.toString error", "Error", MB_OK | MB_ICONEXCLAMATION ); }
            }
        }
    }

    static
    extern( Windows ) nothrow 
    LRESULT WindowProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
    {
        switch( message )
        {
            case WM_CREATE : { return on_WM_CREATE(  hwnd, message, wParam, lParam ); }
            case WM_PAINT  : { return on_WM_PAINT(   hwnd, message, wParam, lParam ); }
            case WM_DESTROY: { return on_WM_DESTROY( hwnd, message, wParam, lParam ); }
            default:
                WindowManager.event( hwnd, message, wParam, lParam );
                return DefWindowProc( hwnd, message, wParam, lParam );
        }
    }

    static
    auto on_WM_CREATE( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
    {
        return 0;
    }

    static
    auto on_WM_PAINT( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
    {
        HDC         hdc;
        PAINTSTRUCT ps; 
        //RECT        crect;
        hdc = BeginPaint( hwnd, &ps );
        //GetClientRect( hwnd, &crect );
        EndPaint( hwnd, &ps ) ;

        return 0;
    }

    static
    auto on_WM_DESTROY( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
    {
        WindowManager.unregister( hwnd );

        PostQuitMessage(0);
        return 0;
    }
}
