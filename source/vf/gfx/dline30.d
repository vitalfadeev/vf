module vf.gfx.dline30;


version(X86_64)
version(Win64)
{
    //
}
else  // native D
{
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
}
