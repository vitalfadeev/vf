module vf.gfx.raster;

// .........
// ^
// cursor here
//
// h line( 1 )
// 1px
// #........
// ^
// cursor here
//
// h line( 2 )
// 2px
// ##.......
//  ^
// cursor here


struct Raster(T,W,H)
{
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

    auto ref line( W w, H h )
    {
        auto absw = ABS( w );
        auto absh = ABS( h );

        if ( w == 0 && h == 0 )
            {}
        else
        if ( h == 0 )                    // -
            h_line( w, absw );
        else
        if ( w == 0 )                    // |
            v_line( h, absh );
        else
            d_line( w, h, absw, absh );  // /

        return this;
    }

    auto ref h_line(W)( W w )
    {
        return h_line( w, ABS(w) );
    }

    auto ref h_line(W,AW)( W w, AW absw )
    in 
    {
        assert( w != 0 );
    }
    do
    {
        auto _current = this.current;           // local var for optimization
        auto _color   = this.color;             //   put in to CPU registers
                                                //   LDC optimize local vars
        auto _x_inc =
            ( w < 0 ) ?
                -(T.sizeof) :  // ← - 
                 (T.sizeof) ;  // → + 

        auto _limit = _current + absw * _x_inc;

        // x++
        //   =color
        for ( ; _current != _limit; _current+=_x_inc )
        {
            // weight
            auto wei = 5;
            auto _wei_inc = pitch;
            auto _wei_current = _current - wei/2*_wei_inc;
            auto _wei_color = T(0,0,0,255);

            foreach( i; 0..wei )
            {
                *( cast(T*)_wei_current ) = _wei_color;
                _wei_current += _wei_inc;
            }

            // base line
            *( cast(T*)_current ) = _color;            
        }

        _current -= _x_inc;  // back 1. set cursor on last pixel
        current = _current;

        return this;
    }

    auto ref v_line(H)( H h )
    {
        return v_line( h, ABS(h) );
    }

    auto ref v_line(H,AH)( H h, AH absh )
    in
    {
        assert( h != 0 );
    }
    do
    {
        auto _current = current;
        auto _color   = color;

        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch ) :  // ↑ -
                (  pitch ) ;  // ↓ +

        auto _limit = _current + absh * _y_inc;

        // y++
        //   =color
        for ( ; _current != _limit; _current+=_y_inc )
            *( cast(T*)_current ) = _color;

        _current -= _y_inc;  // back 1. set cursor on last pixel
        current = _current;

        return this;
    }

    auto ref d_line( W w, H h )
    {
        return d_line( w, h, ABS(w), ABS(h) );
    }

    auto ref d_line(W,H,AW,AH)( W w, H h, AW absw, AH absh )
    {
        if ( absw == absh )
            return d_line_45( w, h, absw, absh );        // 45 degress /
        else
        if ( absw > absh )
            return d_line_30( w, h, absw, absh );        // 0..45 degress
        else
            return d_line_60( w, h, absw, absh );        // 45..90 degress
    }

    auto ref d_line_45(W,H,AW,AH)( W w, H h, AW absw, AH absh )
    in
    {
        assert( w != 0 );
        assert( h != 0 );
    }
    do
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

        auto _inc   = _x_inc + _y_inc;
        auto _limit = _current + _inc * absh;

        for ( ; _current != _limit; _current+=_inc )
            *( cast(T*)_current ) = _color;

        _current -= _inc;  // back 1. set cursor on last pixel
        current = _current;

        return this;
    }

    auto ref d_line_30(W,H,AW,AH)( W w, H h, AW absw, AH absh )
    in
    {
        assert( w != 0 );
        assert( h != 0 );
    }
    do
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

        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch ) :  // -  ↖↗
                (  pitch ) ;  // +  ↙↘

        auto _x_inc =
            ( w < 0 ) ?
                ( -T.sizeof ) :  // - ↙↖
                (  T.sizeof ) ;  // + ↗↘

        //
        auto barw = absw / absh;
        auto _    = absw % absh;

        alias TBARW = typeof(barw);
        TBARW bar1;  // width of bar 1
        TBARW bar2;
        TBARW bar2n;
        TBARW bar3;

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

        // 0..1
        if (bar1)
        {
            _color = T( 0, 255, 0, 0);

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
            _color = T( 0, 255, 255, 0);

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

            if ( bar3 == 0 )
                _current -= _x_limit_inc;  // back 1. set cursor on last pixel
        }

        // 3..4
        if (bar3)
        {
            _color = T( 255, 0, 255, 0);

            auto _limit = _current + (bar3) * _x_inc;

            // x++
            //   = color
            for ( ; _current != _limit; _current+=_x_inc )
                *( cast(T*)_current ) = _color;

            _current -= _x_inc;  // back 1. set cursor on last pixel
        }

        current = _current;

        return this;
    }

    auto ref d_line_60(W,H,AW,AH)( W w, H h, AW absw, AH absh )
    in
    {
        assert( w != 0 );
        assert( h != 0 );
    }
    do
    {
        auto _current = current;
        auto _color   = color;

        auto barh = absh / absw;
        auto _    = absh % absw;

        alias TBARW = typeof(barh);
        TBARW bar1;  // height of bar 1
        TBARW bar2;
        TBARW bar2n;
        TBARW bar3;

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
            _color = T( 0, 255, 0, 0);

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
            _color = T( 0, 255, 255, 0);

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

            if ( bar3 == 0 )
                _current -= _y_limit_inc;  // back 1. set cursor on last pixel
        }

        // 3..4
        if (bar3)
        {
            _color = T( 255, 0, 255, 0);

            auto _limit = _current + (bar3) * _y_inc;

            // y++
            //   = color
            for ( ; _current != _limit; _current+=_y_inc )
                *( cast(T*)_current ) = _color;

            _current -= _y_inc;  // back 1. set cursor on last pixel
        }

        current = _current;

        return this;
    }

    auto ref go_center()
    {
        current = 
            (cast(void*)pixels.ptr) + 
            h / 2 * pitch + 
            w / 2 * T.sizeof;
        return this;
    }

    auto ref go( W w, H h )
    {
        current = 
            current + 
            h * pitch + 
            w * T.sizeof;

        return this;
    }
}

auto ABS(T)(T a)
{
    return 
        ( a < 0 ) ? 
            (-a):
            ( a);
}

