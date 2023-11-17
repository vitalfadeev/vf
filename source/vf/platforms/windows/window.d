module vf.platforms.windows.window;

version(WINDOWS):
import core.sys.windows.windows;
import vf.event          : Event, EventType;
import vf.interfaces     : IWindow, ISensAble;
import vf.types          : PX, WindowsException, W, H;


class Window : IWindow, ISensAble
{
    HWND hwnd;

    alias T = typeof(this);


    this( PX size=PX(640,480), string name="Windows Window", int cmd_show=1 )
    {
        _create_window( size, name, cmd_show );
        _create_renderer();
    }

    //
    void sense( Event* event, EventType event_type ) 
    {
        DefWindowProc( event.msg.hwnd, event_type, event.msg.wParam, event.msg.lParam );
    }

    // private
    private
    void _create_window( PX size, string name, int cmd_show )
    {
        import std.utf : toUTF16z;
        import std.traits;

        HINSTANCE hInstance = GetModuleHandle(NULL);
        
        auto className = toUTF16z( fullyQualifiedName!(typeof(this)) );
        WNDCLASS wndClass;

        // Create Window Class
        wndClass.style         = CS_HREDRAW | CS_VREDRAW;
        wndClass.lpfnWndProc   = &window_proc_sense;
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
}


extern( Windows ) 
nothrow
LRESULT window_proc_sense( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
{   //              RCX,       RDX,            R8,            R9
    import vf.event          : Event, EventType;
    import vf.types          : show_throwable;
    import vf.window_manager : WindowManager;

    Event event;
    event.msg.message = message;
    event.msg.hwnd    = hwnd;
    event.msg.wParam  = wParam;
    event.msg.lParam  = lParam;
    alias event_type  = message;
    try {
        WindowManager.instance.sense( &event, event_type );
    } catch ( Throwable o ) { o.show_throwable; }
    return DefWindowProc( hwnd, message, wParam, lParam );
}



void auto_route_event( alias This, alias event, alias event_type )()
{
    mixin( _auto_route_event!( This, event, event_type )() );
}

string _auto_route_event( alias This, alias event, alias event_type )()
{
    import std.traits;
    import std.string;
    import std.format;
    import vf.traits;

    alias T = typeof( This );

    string s;
    s ~= "import core.sys.windows.windows;";

    s ~= "switch (event_type) {";

    static foreach( h; Handlers!T )
        s ~= "case "~(HandlerName!h)[3..$]~":  { This."~(HandlerName!h)~"( event, event_type ); break; } ";

    //
        s ~= "default: DefWindowProc( event.msg.hwnd, event_type, event.msg.wParam, event.msg.lParam );";

    s ~= "}";

    return s;
}


import vf.platforms.windows.raster;
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
