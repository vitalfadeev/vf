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
            h_line( wh.x );
        else
        if ( wh.x == 0 )                    // |
            v_line( wh.y );
        else
        if ( ABS( w ) == ABS( h ) )
            d_line_45( wh.x, wh.y );        // 45 degress /
        else
        if ( ABS(wh.x) > ABS(wh.y) )
            d_line_30( wh.x, wh.y );        // /
        else
            d_line_60( wh.x, wh.y );        // /
    }

    //pragma( inline, true )
    auto ref h_line( W w )
    {
        auto _current = this.current;           // local var for optimization
        auto _color   = this.color;             //   put in to CPU registers
                                                //   LDC optimize local vars

        auto _inc =
            ( w < 0 ) ?
                -(T.sizeof) :  // -
                 (T.sizeof) ;  // +

        auto _limit = _current + ABS(w) * _inc;

        for ( ; _current != _limit; _current+=_inc )
            *( cast(T*)_current ) = _color;

        current = _current;

        return this;
    }

    auto ref v_line( H h )
    {
        auto _current = current;
        auto _color   = color;

        auto _inc =
            ( h < 0 ) ?
                -(pitch) :  // -
                 (pitch) ;  // +

        auto _limit = _current + ABS(h) * _inc;

        for ( ; _current != _limit; _current+=_inc )
            *( cast(T*)_current ) = _color;

        current = _current;

        return this;
    }

    auto ref d_line( W w, H h )
    {
        if ( ABS( w ) == ABS( h ) )
            return d_line_45( w, h );        // 45 degress /
        else
        if ( ABS( w ) > ABS( h ) )
            return d_line_30( w, h );        // /
        else
            return d_line_60( w, h );        // /
    }

    auto ref d_line_45( W w, H h )
    {
        auto _current = current;
        auto _color   = color;

        
        auto _inc =
            ( h < 0 ) ?
                (  // ↖↗
                    ( w < 0 ) ?
                        -( pitch + T.sizeof ) :  // ↖ -,-
                        -( pitch - T.sizeof )    // ↗ +,-
                ):
                (  // ↙↘
                    ( w < 0 ) ?
                        ( pitch - T.sizeof ) :  // ↙ -,+
                        ( pitch + T.sizeof )    // ↘ +,+
                );

        auto _limit = _current + ABS(w) * _inc;

        for ( ; _current != _limit; _current+=_inc )
            *( cast(T*)_current ) = _color;

        current = _current;

        return this;
    }

    auto ref d_line_30( W w, H h )
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
        //     barw     = ( _x - x ) / ( _y - y )
        //

        // -,-   |   +,-
        //       |     
        // ------+-----> w
        //       |      
        // -,+   v   +,+
        //       h

        auto _current = current;
        auto _color   = color;
        alias T_INC   = typeof( -cast(W)( pitch + T.sizeof ) );
        alias T_LIMIT = typeof( _current );
        T_INC   _inc;
        T_INC   _incx;
        T_LIMIT _limit;

        auto absw = ABS( w );
        auto absh = ABS( h );

        auto barw = absw / absh;
        auto _    = absw % absh;

        int bar1;  // width of bar 1
        int bar2;
        int bar2n;
        int bar3;

        if ( _ == 0 )
        {
            bar1  = barw;
            bar2  = barw;
            bar2n = absh;
            bar3  = barw;
        }
        else
        {        
            bar1  = _ / 2;
            _     = _ % 2;
            bar2  = barw;
            bar2n = absh;
            bar3  = bar1 - _;
        }

        // 0..1
        if (bar1) 
        {
            _inc =
                ( w >= 0 ) ?
                     cast(T_INC)T.sizeof :  // +
                    -cast(T_INC)T.sizeof ;  // -

            _limit = _current + bar1 * _inc;

            for ( ; _current != _limit; _current+=_inc )
                *( cast(T*)_current ) = _color;
        }

        // 1..2..3
        if (bar2)
        {
            // ↙↘
            // ?,+
            if ( h > 0)
            {
                // ↘
                // +,+
                if ( w > 0 )
                {
                    _inc    = cast(T_INC)pitch;
                    _limit  = _current + bar2n * _inc;
                    _incx   = cast(T_INC)T.sizeof;

                    for ( ; _current != _limit; _current+=_inc )
                    {
                        auto _limitx = _current + bar2 * _incx;
                        for ( ; _current != _limitx; _current+=_incx )
                            *( cast(T*)_current ) = _color;
                    }
                }
                else
                // ↙
                // -,+
                {
                    _inc    = cast(T_INC)pitch;
                    _limit  = _current + bar2n * _inc;
                    _incx   = -cast(T_INC)T.sizeof;

                    for ( ; _current != _limit; _current+=_inc )
                    {
                        auto _limitx = _current - bar2 * _incx;
                        for ( ; _current != _limitx; _current+=_incx )
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
                    _inc   = -cast(T_INC)pitch;
                    _limit = _current + bar2n * _inc;
                    _incx  = cast(T_INC)T.sizeof;

                    for ( ; _current != _limit; _current+=_inc )
                    {
                        auto _limitx = _current - bar2 * _incx;
                        for ( ; _current != _limitx; _current+=_incx )
                            *( cast(T*)_current ) = _color;
                    }
                }
                else
                // ↖
                // -,-
                {
                    _inc   = -cast(T_INC)pitch;
                    _limit = _current + bar2n * _inc;
                    _incx  = -cast(T_INC)T.sizeof;

                    for ( ; _current != _limit; _current+=_inc )
                    {
                        auto _limitx = _current + bar2 * _incx;
                        for ( ; _current != _limitx; _current+=_incx )
                            *( cast(T*)_current ) = _color;
                    }
                }
            }
        }

        // 3..4
        if (bar3)
        {
            // +
            if ( w > 0 )
            {
                _inc   = cast(T_INC)T.sizeof;
                _limit = _current + bar3 * _inc;
            }
            else
            // -
            {
                _inc   = -cast(T_INC)T.sizeof;
                _limit = _current + bar3 * _inc;
            }            

            for ( ; _current != _limit; _current+=_inc )
                *( cast(T*)_current ) = _color;
        }

        current = _current;

        return this;
    }

    auto ref d_line_60(W,H)( W w, H h )
    {
        auto _current = current;
        auto _color   = color;

        auto padh = h / w;
        auto _    = h % w;

        int pad1;
        int pad2;
        int pad2n;
        int pad3;

        if ( _ == 0 )
        {
            pad1  = padh;
            pad2  = padh;
            pad2n = w;
            pad3  = padh;
        }
        else
        {        
            pad1  = _ / 2;
            _     = _ % 2;
            pad2  = padh;
            pad2n = w;
            pad3  = pad1 - _;
        }

        // 0..1
        if (pad1) 
        {
            // +
            if ( w > 0 )
            {
                auto _inc   = pitch;
                auto _limit = _current + pad1 * _inc;

                for ( ; _current < _limit; _current+=_inc )
                    *( cast(T*)_current ) = _color;
            }
            else
            // -
            {
                auto _inc   = pitch;
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
                    auto _incx   = T.sizeof;
                    auto _limitx = _current + pad2 * _incx;

                    for ( ; _current < _limitx; _current+=_incx )
                    {
                        auto _limit  = _current + pad2n * _inc;
                        for ( ; _current < _limit; _current+=_inc )
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

    auto ref go_center()
    {
        current = (cast(void*)pixels.ptr) + h / 2 * pitch + w / 2 * T.sizeof;
        return this;
    }

    auto ref go( W w, H h )
    {
        current = (cast(void*)pixels.ptr) + h * pitch + w * T.sizeof;
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
        ( a < 0 ) ? 
            (-a):
            ( a);
}
