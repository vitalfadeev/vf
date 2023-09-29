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

    auto ref line( PX a, PX b )
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
        {
            auto absw = ABS( w );
            auto absh = ABS( h );

            if ( absw == absh )
                d_line_45( w, h, absw, absh );        // 45 degress /
            else
            if ( absw > absh )
                d_line_30( w, h, absw, absh );        // 0..45 degress
            else
                d_line_60( w, h, absw, absh );        // 45..90 degress
        }

        return this;
    }

    //pragma( inline, true )
    auto ref h_line( W w )
    {
        auto _current = this.current;           // local var for optimization
        auto _color   = this.color;             //   put in to CPU registers
                                                //   LDC optimize local vars
        auto _x_inc =
            ( w < 0 ) ?
                -(T.sizeof) :  // - ←
                 (T.sizeof) ;  // + →

        auto _limit = _current + ABS(w) * _x_inc;

        alias _inc = _x_inc;

        for ( ; _current != _limit; _current+=_inc )
            *( cast(T*)_current ) = _color;

        current = _current;

        return this;
    }

    auto ref v_line( H h )
    {
        auto _current = current;
        auto _color   = color;

        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch ) :  // - ↑
                (  pitch ) ;  // + ↓

        auto _limit = _current + ABS(h) * _y_inc;

        alias _inc = _y_inc;

        for ( ; _current != _limit; _current+=_inc )
            *( cast(T*)_current ) = _color;

        current = _current;

        return this;
    }

    auto ref d_line( W w, H h )
    {
        auto absw = ABS( w );
        auto absh = ABS( h );

        if ( absw == absh )
            return d_line_45( w, h, absw, absh );        // 45 degress /
        else
        if ( absw > absh )
            return d_line_30( w, h, absw, absh );        // 0..45 degress
        else
            return d_line_60( w, h, absw, absh );        // 45..90 degress
    }

    auto ref d_line_45(AW,AH)( W w, H h, AW absw, AH absh )
    {
        auto _current = current;
        auto _color   = color;
        
        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch ) :  // -  ↖↗
                (  pitch ) ;  // +  ↙↘

        auto _x_inc =
            ( w < 0 ) ?
                ( -T.sizeof ) :  // - ↙↖
                (  T.sizeof ) ;  // + ↗↘

        auto _limit = _current + absh * _y_inc + absw * _x_inc;
        auto _inc   = _x_inc + _y_inc;

        for ( ; _current != _limit; _current+=_inc )
            *( cast(T*)_current ) = _color;

        current = _current;

        return this;
    }

    auto ref d_line_30(AW,AH)( W w, H h, AW absw, AH absh )
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

        auto barw = absw / absh;
        auto _    = absw % absh;

        int bar1;  // width of bar 1
        int bar2;
        int bar2n;
        int bar3;

        if ( _ == 0 )
        {
            bar1  = 0;
            bar2  = barw;
            bar2n = absh;
            bar3  = 0;
        }
        else
        {        
            bar1  = barw - _;
            bar2  = barw;
            bar2n = ( absh <= 2 ) ? 0 : absh - 2;
            bar3  = ( absh <= 2 ) ? 0 : barw;
        }

        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch ) :  // -  ↖↗
                (  pitch ) ;  // +  ↙↘

        auto _x_inc =
            ( w < 0 ) ?
                ( -T.sizeof ) :  // - ↙↖
                (  T.sizeof ) ;  // + ↗↘

        // 0..1
        if (bar1)
        {
            _color = RGBQUAD( 0, 255, 0, 0);

            auto _limit = _current + (bar1) * _x_inc;

            // x++
            //   = color
            for ( ; _current != _limit; _current+=_x_inc )
                *( cast(T*)_current ) = _color;

            _current+=_y_inc;
        }

        // 1..2..3
        if (bar2)
        {
            _color = RGBQUAD( 0, 255, 255, 0);

            auto _x_inc_bar2  = _x_inc * (bar2);
            auto _x_limit_inc = _y_inc   + _x_inc_bar2;
            auto _x_limit     = _current + _x_inc_bar2;
            auto _y_limit     = _current + _x_limit_inc * (bar2n);

            // y++
            //   x++
            //     = color
            for ( ; _current != _y_limit; _current+=_y_inc, _x_limit+=_x_limit_inc )
                for ( ; _current != _x_limit; _current+=_x_inc )
                    *( cast(T*)_current ) = _color;
        }

        // 3..4
        if (bar3)
        {
            _color = RGBQUAD( 255, 0, 255, 0);

            auto _limit = _current + (bar3) * _x_inc;

            // x++
            //   = color
            for ( ; _current != _limit; _current+=_x_inc )
                *( cast(T*)_current ) = _color;

            _current+=_y_inc;
        }

        current = _current;

        return this;
    }

    auto ref d_line_60(AW,AH)( W w, H h, AW absw, AH absh )
    {
        auto _current = current;
        auto _color   = color;

        auto barh = absh / absw;
        auto _    = absh % absw;

        int bar1;  // width of bar 1
        int bar2;
        int bar2n;
        int bar3;

        if ( _ == 0 )
        {
            bar1  = 0;
            bar2  = barh;
            bar2n = absw;
            bar3  = 0;
        }
        else
        {        
            bar1  = barh - _;
            bar2  = barh;
            bar2n = ( absw <= 2 ) ? 0 : absw - 2;
            bar3  = ( absw <= 2 ) ? 0 : barh;
        }

        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch ) :  // -  ↖↗
                (  pitch ) ;  // +  ↙↘

        auto _x_inc =
            ( w < 0 ) ?
                ( -T.sizeof ) :  // - ↙↖
                (  T.sizeof ) ;  // + ↗↘

        // 0..1
        if (bar1)
        {
            _color = RGBQUAD( 0, 255, 0, 0);

            auto _limit = _current + (bar1) * _y_inc;

            // y++
            //   = color
            for ( ; _current != _limit; _current+=_y_inc )
                *( cast(T*)_current ) = _color;

            _current+=_x_inc;
        }

        // 1..2..3
        if (bar2)
        {
            _color = RGBQUAD( 0, 255, 255, 0);

            auto _y_inc_bar2  = _y_inc * (bar2);
            auto _y_limit_inc = _x_inc   + _y_inc_bar2;
            auto _y_limit     = _current + _y_inc_bar2;
            auto _x_limit     = _current + _y_limit_inc * (bar2n);

            // x++
            //   y++
            //     = color
            for ( ; _current != _x_limit; _current+=_x_inc, _y_limit+=_y_limit_inc )
                for ( ; _current != _y_limit; _current+=_y_inc )
                    *( cast(T*)_current ) = _color;
        }

        // 3..4
        if (bar3)
        {
            _color = RGBQUAD( 255, 0, 255, 0);

            auto _limit = _current + (bar3) * _y_inc;

            // y++
            //   = color
            for ( ; _current != _limit; _current+=_y_inc )
                *( cast(T*)_current ) = _color;

            _current+=_x_inc;
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
        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch ) :  // -  ↖↗
                (  pitch ) ;  // +  ↙↘

        auto _x_inc =
            ( w < 0 ) ?
                ( -T.sizeof ) :  // - ↙↖
                (  T.sizeof ) ;  // + ↗↘

        auto _inc = ABS(h) * _y_inc + ABS(w) * _x_inc;

        current = (cast(void*)current) + _inc;

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
