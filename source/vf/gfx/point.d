module vf.gfx.point;

extern(C)
void point(T=int)( T* current, T color )
{
    *current = color;
}

version( ASM )
{
    import ldc.llvmasm;
    import ldc.attributes;
    
    __asm("
        movl    %esi, (%rdi)
        retq
        ",
        ""
    );
}
