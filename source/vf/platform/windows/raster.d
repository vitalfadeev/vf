module vf.platform.windows.raster;

version(WINDOWS_NATIVE):
import core.sys.windows.windows;
import vf.types;
import vf.color;
import vf.ui.window;
import vf.gfx.raster;


struct Raster
{
    alias T = RGBQUAD;
    vf.gfx.raster.Raster!(T,W,H) _super;
    alias _super this;

    this( T[] pixels, W w, H h, size_t pitch, void*  current, T color )
    {
        this.pixels  = pixels;
        this.w       = w;
        this.h       = h;
        this.pitch   = pitch;
        this.current = current;
        this.color   = color;
    }

    auto ref line( PX px )
    {
        _super.line( px.x, px.y );
        return this;
    }
}


auto ref to(T:Window)( Raster This, Window window, HDC hdc )
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
