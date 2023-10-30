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
/*
    auto ref point()
    {
        import vf.gfx.point;
        point( current, color );
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
        if ( ph == 0 )                     // -
            h_line( absw, w, color, current );
        else
        if ( pw == 0 )                     // |
            v_line( absh, h, color, current, pitch );
        else
            d_line( absh, h, color, current, pitch );  // /
                //( pw, ph, absw, absh )

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
    */
}
/*
auto ABS(T)(T a)
{
    return 
        ( a < 0 ) ? 
            (-a):
            ( a);
}

*/
