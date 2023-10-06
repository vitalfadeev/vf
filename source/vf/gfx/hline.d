module vf.gfx.hline;


version(X86_64)
version(Win64)
{
    // ldc.simd
    // ldc.llvmasm;
    import ldc.attributes;
    pragma( inline, false )
    void h_line(T)( PX px, T color, T* current )
        if ( PX.sizeof == 32 && T.sizeof == 32 )
    {   //             RCX,  RDX,      R8
        //             x,y   RGBA
        //             16,16 8,8,8,8   addr
        // MS 
        //   x86_64: RCX, RDX, R8, R9
        //     preserved:  RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are considered nonvolatile (callee-saved)
        //     scratch:    RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile (caller-saved)
        //
        // linux
        //   x86_64: RDI, RSI, RDX, RCX, R8, R9
        //     preserved:  RBX, RSI, RDI, RBP
        //     scratch:    RAX, RCX, RDX

        import ldc.llvmasm;
        // void __asm (char[] asmcode, char[] constraints, [ Arguments... ] );
        // constraints: outputs, inputs and clobbers
        //   output: 
        //     =*m == memory output
        //     =r  == general purpose register output
        //   input:
        //     *m == memory input
        //     r  == general purpose register input
        //     i  == immediate value input
        //   clobbers:
        //     ~{memory} == clobbers memory

        pragma(LDC_never_inline);
        __asm("
                .intel_syntax noprefix;

                mov   r8, rcx   # save rcx
                movzx cx, r8w   # 0.0.x.y
                shr   ecx, 16   # .x

                test  cx, cx    # if x < 0
                js TO_LEFT      #   left
                                # else right
            TO_RIGHT:           #   
                cld             #   right
                dec   cx        #   count--
                jmp LOOP

            TO_LEFT:            # left
                std             #   left
                neg   cx        #   ABS(x)
                inc   cx        #   count++

            LOOP:
                 mov  rdi, r9   #  current
                 mov  rax, r8   #  color
                 rep  stosd     #  for w..0: *current = color

                 mov dword ptr [rdi], rax  # *_current = _color;
            ", 
            "~{memory},~{flags},~{rax},~{rdi},~{rsi},~{rcx},~{r8}"
        );
    }
}
else  // native D
{
    import ldc.attributes;
    pragma( inline, false )
    @optStrategy("minsize")// minsize,none,optsize
    void h_line(T)( PX px, T color, ref T* current )
    in
    {
        assert( px.x != 0 );
    }
    do
    {
        //pragma(LDC_allow_inline)
        pragma(LDC_never_inline);

        auto _current = current;
        auto _color   = color;

        // x++
        //   =color
        if ( px.x < 0 )  // ←
        {
            auto _count = -px.x + 1;
            for ( ; _count; _count--, _current-- )
                *_current = _color;
        }
        else  // →
        {
            auto _count = px.x - 1;
            for ( ; _count; _count--, _current++ )
                *_current = _color;
        }

        *_current = _color;

        current = _current;
    }
}
