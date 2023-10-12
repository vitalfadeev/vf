module vf.gfx.dline30;


version(X86)
{
// D_LINE_30:
// mov  cx, length      // _line_length_by_x
// test cx, cx
//   jz   ok            // if count == 0 goto ok
//
// mov  esi, pitch      // _y_inc
// mov  eax, color      // color
// cld                  // direction +
//
// loop:
//   stosd              // POINT(x,y,color)
//                      //   add di, 4  // x += _x_inc
//                      // or 
//                      // mov %eax, (%edi)
//
//   dec  cx            // count--
//   jz   ok            // if count == 0 goto ok
//           
//   dec  dx            // fraq--
//   jnz  next_x        // if fraq == 0
//     add  di, si      //   y++
//     mov  dx, bx      //   fraq = x_base
//
//   next_x:
//     jmp loop
//
// ok:
//   //
}
else  // native D
{
    pragma( inline, false )
    auto ref d_line_30( int* current, int color, int wh, int pitch )
    {
        auto w = (wh >> 16) & 0xFFFF;
        auto h = wh & 0xFFFF;

        auto _dst   = current;
        auto _color = color;
        auto _count = ABS(w);

        auto _x_inc = color.sizeof;
        auto _y_inc = pitch;

        auto _fraq_base = w/h;
        auto _fraq      = _fraq_base;

        if ( _count == 0 )
            return;

        while (1)
        {
            *_dst = color;

            _count--;
            if ( _count == 0 )
                break;

            _fraq--;
            if ( _fraq == 0 )
            {
                _dst += _y_inc;
                _fraq = _fraq_base;
            }

            _dst += _x_inc;
        }
    }
}


// y    y'
// - = ---
// x   x+1
//
// y' = y(x+1)/x = yx/x + y/x = y + y/x
// y' = y + y/x
//
// y/x = ... y on x-based system = fraq
//
// x++
// fraq++
// if fraq == x 
//   y++
//   fraq = 0
// 
// optimized
// x++
// fraq--
// if flags.zero   // fraq == 0
//   y++
//   fraq = fraq_init = x_base
//
