module vf.platform.xlib.raster;

version(XLIB):
import xcb.xcb;
import vf.types;
import vf.gfx.raster;

alias RGBQUAD = int;


class Raster : vf.gfx.raster.Raster!(RGBQUAD,W,H)
{
    alias T = RGBQUAD;

    this( T[] pixels, W w, H h, size_t pitch, T*  current, T color )
    {
        this.pixels  = pixels;
        this.w       = w;
        this.h       = h;
        this.pitch   = pitch;
        this.current = current;
        this.color   = color;
    }

    typeof(this) go( PX px )
    {
        super.go( px.x, px.y );
        return this;
    }

    typeof(this) line( PX px )
    {
        super.line( px.x, px.y );
        return this;
    }
}


import vf.ui.window;
WINDOW to_window(WINDOW:Window)( Raster This, WINDOW window, HDC hdc )
    // if ( WINDOW inherited from Window )
{
    auto pixels = This.pixels.ptr;
    auto hwnd   = window.hwnd;

    RECT rect;
    int  window_width;
    int  window_height;
    if ( GetWindowRect( hwnd, &rect ) )
    {
      window_width  = rect.right - rect.left;
      window_height = rect.bottom - rect.top;
    }
    else
    {
        throw new WindowsException( "GetWindowRect: " );
    }

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
        biClrUsed       = 0;
        biClrImportant  = 0;
    }

    SetDIBitsToDevice(
        /*hdc*/         hdc,
        /*xDest*/       0,
        /*yDest*/       0,
        /*w*/           window_width,
        /*h*/           window_height,
        /*xSrc*/        0,
        /*ySrc*/        0,
        /*StartScan*/   0,
        /*cLines*/      window_height,
        /*lpvBits*/     pixels,
        /*lpbmi*/       &bmi,
        /*ColorUse*/    DIB_RGB_COLORS
    );

    return window;
}


// Window -> Raster
// Window
// on_XCB_EXPOSE(...):
//   this
//     .to_painter()       // window  -> painter
//       .go_center()
//       .go( 0, +10 )
//       .line( +5,0 )     
//     .to_raster( this )  // painter -> raster
//     .to_window( this ); // raster  -> window
Raster to_raster( Window This, xcb_connection_t *c )
{
    return Raster();
}
/+
Raster to_raster( Window This, xcb_connection_t *c )
{
    xcb_pixmap_t pixmap = xcb_generate_id( c );

    /* Create a black graphic context for drawing in the foreground */
    xcb_drawable_t win   = This.win;
    xcb_gcontext_t gc    = xcb_generate_id( c );
    uint32_t       mask  = XCB_GC_FOREGROUND;
    uint32_t[1]    value = This.screen.black_pixel;
    
    xcb_void_cookie_t cookie_gc = 
        xcb_create_gc( c, gc, win, mask, value );

    // Get pixel
    uint32_t pixel = xcb_image_get_pixel(xcb_image_get(conn, screen->root, x, y, 1, 1, AllPlanes, XYPixmap), 0, 0);

    xcb_void_cookie_t area = 
        xcb_copy_area (
            This.c,             // Pointer to the xcb_connection_t structure 
            This.win,           // The Drawable we want to paste 
            pixmap,             // The Drawable on which we copy the previous Drawable 
            gc,                 // A Graphic Context 
            int16_t           src_x,         // Top left x coordinate of the region we want to copy 
            int16_t           src_y,         // Top left y coordinate of the region we want to copy 
            int16_t           dst_x,         // Top left x coordinate of the region where we want to copy 
            int16_t           dst_y,         // Top left y coordinate of the region where we want to copy 
            uint16_t          width,         // Width of the region we want to copy 
            uint16_t          height         // Height of thgion
        );


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
+/