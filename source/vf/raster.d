module vf.raster;

version(WINDOWS_NATIVE):
import core.sys.windows.windows;
import vf.types;
import vf.color;
import vf.ui.window;


struct Raster
{
    alias T = RGBQUAD;

    T[]    pixels;
    W      w;
    H      h;
    size_t pitch;
    void*  current;
    T      color;

    auto ref point()
    {
        *(cast(T*)current) = color;
        return this;
    }

    void line( PX a, PX b )
    {
        auto wh = b - a;

        if ( wh.x == 0 && wh.y == 0 )
            {}
        else
        if ( wh.y == 0 )                    // -
            h_line( wh.y );
        else
        if ( wh.x == 0 )                    // |
            v_line( wh.y );
        else
        if ( wh.x == wh.y )
            d_line_45( wh.x, wh.y );        // 45 degress /
        else
            d_line( wh.x, wh.y );           // /
    }

    //pragma( inline, true )
    auto ref h_line(W)( W w )
    {
        auto _current = this.current;           // local var for optimization
        auto _color   = this.color;             //   put in to CPU registers
                                                //   LDC optimize local vars
        // +
        if ( w > 0 )
        {
            auto _inc   = T.sizeof;
            auto _limit = _current + w * _inc;

            for ( ; _current < _limit; _current+=_inc )
                *( cast(T*)_current ) = _color;
        }
        else
        // -
        {
            auto _inc   = T.sizeof;
            auto _limit = _current + w * _inc;

            for ( ; _current > _limit; _current-=_inc )
                *( cast(T*)_current ) = _color;
        }

        current = _current;

        return this;
    }

    auto ref v_line(H)( H h )
    {
        auto _current = current;
        auto _color   = color;

        // +
        if ( h > 0 )
        {
            auto _inc   = pitch;
            auto _limit = _current + h * pitch;

            for ( ; _current < _limit; _current+=_inc )
                *( cast(T*)_current ) = _color;            
        }
        else
        // -
        {
            auto _inc   = pitch;
            auto _limit = _current + h * pitch;

            for ( ; _current > _limit; _current-=_inc )
                *( cast(T*)_current ) = _color;
        }

        current = _current;

        return this;
    }

    auto ref d_line(W,H)( W w, H h )
    {
        //                                                          y
        // 0                       1                        2    // _y - y = 1
        // #########################                             // 0
        //                          #########################    // 1
        //
        //
        // 0               1                2               3_   // _y - y = 2
        // #################                                     // 0
        //                  #################                    // 1
        //                                   ################    // 2
        //
        // 0      1                2                3       4    // _y - y = 2
        // ########                                              // 2_
        //         #################                             // 0
        //                          #################            // 1
        //                                           ########    // _2
        //
        //
        // 0          1            2            3           4    // _y - y = 3
        // ############                                          // 0
        //             #############                             // 1
        //                          #############                // 2
        //                                       ############    // 3
        //                                                          y
        // |<-------->|
        //     padw     = ( _x - x ) / ( _y - y )
        //

        // -,-   |   +,-
        //       |     
        // ------+-----> u
        //       |      
        // -,+   v   +,+
        //       c

        auto _current = current;
        auto _color   = color;

        auto padw = w / h;
        auto _    = w % h;

        int pad1;
        int pad2;
        int pad2n;
        int pad3;

        if ( _ == 0 )
        {
            pad1  = padw;
            pad2  = padw;
            pad2n = h;
            pad3  = padw;
        }
        else
        {        
            pad1  = _ / 2;
            _     = _ % 2;
            pad2  = padw;
            pad2n = h;
            pad3  = pad1 - _;
        }

        // 0..1
        if (pad1) 
        {
            // +
            if ( w > 0 )
            {
                auto _inc   = T.sizeof;
                auto _limit = _current + pad1 * _inc;

                for ( ; _current < _limit; _current+=_inc )
                    *( cast(T*)_current ) = _color;
            }
            else
            // -
            {
                auto _inc   = T.sizeof;
                auto _limit = _current + pad1 * _inc;

                for ( ; _current > _limit; _current-=_inc )
                    *( cast(T*)_current ) = _color;
            }
        }

        // 1..2..3
        if (pad2)
        {
            // ↙↘
            // ?,+
            if ( h > 0)
            {
                // ↘
                // +,+
                if ( w > 0 )
                {
                    auto _inc    = pitch;
                    auto _limit  = _current + pad2n * _inc;
                    auto _incx   = T.sizeof;

                    for ( ; _current < _limit; _current+=_inc )
                    {
                        auto _limitx = _current + pad2 * _incx;
                        for ( ; _current < _limitx; _current+=_incx )
                            *( cast(T*)_current ) = _color;
                    }
                }
                else
                // ↙
                // -,+
                {
                    auto _inc    = pitch;
                    auto _limit  = _current + pad2n * _inc;
                    auto _incx   = T.sizeof;

                    for ( ; _current < _limit; _current+=_inc )
                    {
                        auto _limitx = _current + pad2 * _incx;
                        for ( ; _current > _limitx; _current-=_incx )
                            *( cast(T*)_current ) = _color;
                    }
                }
            }
            else
            // ↖↗
            // ?,-
            {
                // ↗
                // +,-
                if ( w > 0 )
                {
                    auto _inc   = pitch;
                    auto _limit = _current + pad2n * _inc;
                    auto _incx  = T.sizeof;

                    for ( ; _current > _limit; _current-=_inc )
                    {
                        auto _limitx = _current - pad2 * _incx;
                        for ( ; _current < _limitx; _current+=_incx )
                            *( cast(T*)_current ) = _color;
                    }
                }
                else
                // ↖
                // -,-
                {
                    auto _inc   = pitch;
                    auto _limit = _current + pad2n * _inc;
                    auto _incx  = T.sizeof;

                    for ( ; _current > _limit; _current-=_inc )
                    {
                        auto _limitx = _current - pad2 * _incx;
                        for ( ; _current > _limitx; _current-=_incx )
                            *( cast(T*)_current ) = _color;
                    }
                }
            }
        }

        // 3..4
        if (pad3)
        {
            // +
            if ( w > 0 )
            {
                auto _inc   = T.sizeof;
                auto _limit = _current + pad3 * _inc;

                for ( ; _current < _limit; _current+=_inc )
                    *( cast(T*)_current ) = _color;
            }
            else
            // -
            {
                auto _inc   = T.sizeof;
                auto _limit = _current + pad3 * _inc;

                for ( ; _current > _limit; _current-=_inc )
                    *( cast(T*)_current ) = _color;
            }            
        }

        current = _current;

        return this;
    }

    auto ref d_line_45( W w, H h )
    {
        auto _current = current;
        auto _color   = color;

        // ↙↘
        // ?,+
        if ( h > 0)
        {
            // ↘
            // +,+
            if ( w > 0 )
            {
                auto _inc   = pitch + T.sizeof;
                auto _limit = _current + h * _inc;

                for ( ; _current < _limit; _current+=_inc )
                    *( cast(T*)_current ) = _color;
            }
            else
            // ↙
            // -,+
            {
                auto _inc   = pitch - T.sizeof;
                auto _limit = _current + h * _inc;

                for ( ; _current < _limit; _current+=_inc )
                    *( cast(T*)_current ) = _color;
            }                
        }
        else
        // ↖↗
        // ?,-
        {
            // ↗
            // +,-
            if ( w > 0 )
            {
                auto _inc   = pitch - T.sizeof;
                auto _limit = _current + h * _inc;

                for ( ; _current > _limit; _current-=_inc )
                    *( cast(T*)_current ) = _color;
            }
            else
            // ↖
            // -,-
            {
                auto _inc   = pitch + T.sizeof;
                auto _limit = _current + h * _inc;

                for ( ; _current > _limit; _current-=_inc )
                    *( cast(T*)_current ) = _color;
            }                
        }

        current = _current;

        return this;
    }

    auto ref go_center()
    {
        current = (cast(void*)pixels.ptr) + h / 2 * pitch + w / 2 * T.sizeof;
        return this;
    }

    void to(T:Window)( HWND hwnd, HDC hdc )
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
            //biXPelsPerMeter = 72;
            //biYPelsPerMeter = 72;
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
            /*lpvBits*/     pixels.ptr,
            /*lpbmi*/       &bmi,
            /*ColorUse*/    DIB_RGB_COLORS
        );
    }
}

auto ABS(T)(T a)
{
    return 
        ( a < 0) ? 
            (-a):
            ( a);
}
