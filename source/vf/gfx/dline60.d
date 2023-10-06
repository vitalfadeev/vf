module vf.gfx.dline60;


version(X86_64)
version(Win64)
{
    //
}
else  // native D
{
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
}
