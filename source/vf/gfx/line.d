module vf.gfx.line;


version=OPTIMIZED_WINDOWS_X86_64;
version(OPTIMIZED_WINDOWS_X86_64)
{
    // inlineIR
    // ldc.simd
    // ldc.llvmasm;
    import ldc.attributes;
    pragma( inline, false )
    //@optStrategy("minsize")// minsize,none,optsize
    void h_line(T)( long absw, long w, T* current, T color )
    {            //       RCX,    RDX,         R8,      R9
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
                test  rdx, rdx
                js TO_LEFT
            TO_RIGHT:
                cld
                jmp LOOP
            TO_LEFT:
                std
            LOOP:
                mov r10, rdi
                 mov  rdi, r8
                 mov  rax, r9
                 repnz stosd
                mov rdi, r10
            ", 
            "~{memory},~{rax},~{rdi},~{rcx},~{r10}", 
        );
    }
}
else
{
    import ldc.attributes;
    pragma( inline, false )
    @optStrategy("minsize")// minsize,none,optsize
    void h_line(T)( long absw, long w, T* current, T color )
    in
    {
        assert( w != 0 );
    }
    do
    {
        //pragma(LDC_allow_inline)
        pragma(LDC_never_inline);

        auto _current = current;

        // x++
        //   =color
        if ( w < 0 )
        {
            auto _count = absw + 1;
            for ( ; _count; _count--, _current-- )
                *_current = color;
        }
        else
        {
            auto _count = absw - 1;
            for ( ; _count; _count--, _current++ )
                *_current = color;
        }

        current = _current;
    }
}
