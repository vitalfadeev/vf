module vf.platforms.windows.raster;

version(WINDOWS):
import core.sys.windows.windows;
import vf.platforms.windows.types;
import vf.gfx.raster;


class Raster : vf.gfx.raster.Raster!(RGBQUAD,W,H)
{
    alias THIS = RGBQUAD;

    this( THIS[] pixels, W w, H h, size_t pitch, THIS*  current, THIS color )
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
        //super.go( px.x, px.y );
        return this;
    }

    typeof(this) line( PX px )
    {
        //super.line( px.x, px.y );
        return this;
    }
}


import vf.platforms.windows.window;
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
