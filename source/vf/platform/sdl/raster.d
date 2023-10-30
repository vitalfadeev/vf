module vf.platform.sdl.raster;

version(SDL):
import bindbc.sdl;
import vf.types;
import vf.color;
import vf.window;
import vf.gfx.raster;


class Raster : vf.gfx.raster.Raster!(SDL_Color,W,H)
{
    alias T = SDL_Color;

    this( T[] pixels, W w, H h, size_t pitch, void*  current, T color )
    {
        this.pixels  = pixels;
        this.w       = w;
        this.h       = h;
        this.pitch   = pitch;
        this.current = current;
        this.color   = color;
    }
}


void to_window( Raster raster, HWND hwnd, HDC hdc )
{
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
        /*lpvBits*/     raster.pixels.ptr,
        /*lpbmi*/       &bmi,
        /*ColorUse*/    DIB_RGB_COLORS
    );
}
