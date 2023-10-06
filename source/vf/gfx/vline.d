module vf.gfx.vline;


version(X86_64)
version(Win64)
{
    import ldc.attributes;
    pragma( inline, false )
    void v_line(T)( long absw, long w, T color, T* current )
    {
        pragma(LDC_never_inline);
        __asm("
                .intel_syntax noprefix;

                test  rdx, rdx  # if w < 0
                js TO_LEFT      #   left
            TO_RIGHT:           # else
                cld             #   right
                jmp LOOP
            TO_LEFT:
                std             # left
            LOOP:
                mov r10, rdi    # save RDI
                 mov  rdi, r9   #  current
                 mov  rax, r8   #  color
                 repnz stosd    #  for w..0: *current = color

                mov rdi, r10    # restore RDI
            ", 
            "~{memory},~{flags},~{rax},~{rdi},~{rcx},~{r10}", 
        );
    }
}
else  // native D
{
    import ldc.attributes;
    pragma( inline, false )
    @optStrategy("minsize")// minsize,none,optsize
    auto ref v_line(T)( long absh, long h, T color, ref T* current, int pitch )
    in
    {
        assert( h != 0 );
    }
    do
    {
        //pragma(LDC_allow_inline)
        pragma(LDC_never_inline);

        auto _current = current;
        auto _color   = color;
        auto _y_inc   = pitch / T.sizeof;

        // x++
        //   =color
        if ( h < 0 )  // ↑
        {
            auto _count = absh + 1;
            for ( ; _count; _count--, _current-=_y_inc )
                *_current = _color;
        }
        else  // ↓
        {
            auto _count = absh - 1;
            for ( ; _count; _count--, _current+=_y_inc )
                *_current = _color;
        }

        *_current = _color;  // last point

        current = _current;
    }
}
