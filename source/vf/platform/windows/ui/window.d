module vf.platform.windows.ui.window;

version(WINDOWS_NATIVE):
import core.sys.windows.windows;
import vf.game;
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

    // private
    private
    void _create_window( PX size, string name )
    {
        import std.utf : toUTF16z;

        HINSTANCE hInstance = GetModuleHandle(NULL);
        int       iCmdShow = 0;
        
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
            className,                        //Window class used.
            "The program".toUTF16z,           //Window caption.
            WS_OVERLAPPEDWINDOW,              //Window style.
            CW_USEDEFAULT,                    //Initial x position.
            CW_USEDEFAULT,                    //Initial y position.
            CW_USEDEFAULT,                    //Initial x size.
            CW_USEDEFAULT,                    //Initial y size.
            null,                             //Parent window handle.
            null,                             //Window menu handle.
            hInstance,                        //Program instance handle.
            null                              //Creation parameters.
        );                           

        if ( hwnd == NULL )
            throw new WindowsException( "Unable to create window"  );

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
    extern( Windows ) nothrow 
    LRESULT WindowProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
    {
        switch( message )
        {
            case WM_CREATE : { return on_WM_CREATE(  hwnd, message, wParam, lParam ); }
            case WM_PAINT  : { return on_WM_PAINT(   hwnd, message, wParam, lParam ); }
            case WM_DESTROY: { return on_WM_DESTROY( hwnd, message, wParam, lParam ); }
            default:
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
        return 0;
    }
}
