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


class Raster(T,W,H)
{
    T[]    pixels;
    W      w;
    H      h;
    size_t pitch;
    T*     current;
    T      color;

    auto ref point()
    {
        *(cast(T*)current) = color;
        return this;
    }

    auto ref line( long pw, H ph )
    {
        import vf.gfx.line;

        auto absw = ABS( pw );
        auto absh = ABS( ph );

        if ( pw == 0 && ph == 0 )
            {}
        else
        if ( ph == 0 )                    // -
            h_line( pw, absw, current, color );
        else
        if ( pw == 0 )                    // |
            v_line( ph, absh );
        else
            d_line( pw, ph, absw, absh );  // /

        return this;
    }


    auto ref v_line(H)( H h )
    {
        return v_line( h, ABS(h) );
    }

    pragma( inline, false )
    //@optStrategy("minsize")// minsize,none,optsize
    auto ref v_line(H,AH)( H h, AH absh )
    in
    {
        assert( h != 0 );
    }
    do
    {
        //auto _current = current;
        auto _color   = color;
        auto _current = cast(T*)current;
        auto _count = absh;
        auto _y_inc = pitch / T.sizeof;

        if ( h < 0 )
        {
            for ( ; _count; _count--, _current-=_y_inc )
                *_current = _color;

            _current += _y_inc;  // back 1. set cursor on last pixel
        }
        else
        {
            for ( ; _count; _count--, _current+=_y_inc )
                *_current = _color;

            _current -= _y_inc;  // back 1. set cursor on last pixel
        }


        //auto _y_inc = 
        //    ( h < 0 ) ?
        //        ( -pitch ) :  // ↑ -
        //        (  pitch ) ;  // ↓ +

        //auto _limit = _current + absh * _y_inc;

        //// y++
        ////   =color
        //for ( ; _current != _limit; _current+=_y_inc )
        //    *( cast(T*)_current ) = _color;

        //_current -= _y_inc;  // back 1. set cursor on last pixel
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

    pragma( inline, false )
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

    pragma( inline, false )
    auto ref d_line_30(W,H,AW,AH)( W w, H h, AW absw, AH absh )
    in
    {
        assert( w != 0 );
        assert( h != 0 );
        assert( absh >= 2 );
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

        auto _current = cast(T*)current;
        auto _color   = color;

        auto _y_inc = 
            ( h < 0 ) ?
                ( -pitch / T.sizeof ) :  // -  ↖↗
                (  pitch / T.sizeof ) ;  // +  ↙↘

        auto _x_inc =
            ( w < 0 ) ?
                ( -T.sizeof ) :  // - ↙↖
                (  T.sizeof ) ;  // + ↗↘

        //
                                       // 8/5
                                       //   5 bars
                                       //   8 pixels
                                       //
                                       // ##......
                                       // . #     
                                       // .  ##   
                                       // .    #  
                                       // .     ##
                                       //
                                       // 5 bars / pairs = 
                                       // 5 bars / 2
        auto pairs = absh / 2;         // = 2 pairs
        auto _     = absh % 2;         // + 1 rest
        auto pl    = ( absw - _ ) / 2; // pair len = 8 - 1 rest / 2 pairs
        auto pl_   = ( absw - _ ) % 2; //          =          7 / 2
                                       //          =          3 (+ 1 rest)
        auto pa = ( pl / 2 ) * 2;      // pair.a = (pair len / 2) * 2 = (3 / 2) * 2 = 2
        auto pb = ( pl % 2 );          // pair.b = (pair len % 2)     = (3 % 2)     = 1
                                       //
                                       // 2 pair
                                       // ##     +_inc_x +_inc_x +_inc_y
                                       //   #                            +_inc_x
        auto tail = 8 - (pl * pairs);  //     ... rest = 8 - (pair len * pairs)
                                       //              = 8 - (3 * 2)
                                       //              = 2

                                       // 8x3
                                       // ##......
                                       // ..####..
                                       // ......##
        // pairs
        for ( ;pairs ;pairs-- )
        {
            // a
            if ( pa )
            {
                for ( auto _counter=pa; _counter; _counter--, _current++ )
                    *_current = _color;

                _current += _y_inc;
            }

            // b
            if ( pb )
            {            
                for ( auto _counter=pb; _counter; _counter--, _current++ )
                    *_current = _color;

                _current += _y_inc;
            }
        }

        // tail
        if ( tail )
        {
            for ( auto _counter=tail; _counter; _counter--, _current++ )
                *_current = _color;

            _current--;
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

        auto splits = absw - 1;

        auto barh = absh / splits;
        auto _    = absh % splits;

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
            bar1  = _;
            bar2  = barh;
            bar2n = splits;
            bar3  = 0;
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
        if (bar3 && 0)
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
            cast(T*)(
                (cast(void*)pixels.ptr) + 
                h / 2 * pitch + 
                w / 2 * T.sizeof
            );
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

