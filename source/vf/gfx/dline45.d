module vf.gfx.dline45;


version(X86_64)
version(Win64)
{
    //
}
else  // native D
{
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
}
