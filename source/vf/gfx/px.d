module px;

// MS 
//   x86_64: RCX, RDX, R8, R9
//     preserved:  RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are considered nonvolatile (callee-saved)
//     scratch:    RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile (caller-saved)
//
// linux
//   x86_64: RDI, RSI, RDX, RCX, R8, R9
//     preserved:  RBX, RSI, RDI, RBP
//     scratch:    RAX, RCX, RDX
version(X86_64)
{
    version(Windows)
    {
        alias AR1 = "RCX";
        alias AR2 = "RDX";
        alias AR3 = "R8";
        alias AR4 = "R9";
    }
    version(linux)
    {
        alias AR1 = "RDI";
        alias AR2 = "RSI";
        alias AR3 = "RDX";
        alias AR4 = "RCX";
        // R8, R9
    }

    alias M64 = ulong;
    alias REG = M64;
}

version(X86)  // 32 bit registers
{
    version(Windows)
    {   // pass arguments on the stack
        // thiscall
        alias AR1 = "ECX";
        alias AR2 = "";
        alias AR3 = "";
        alias AR4 = "";
        //// fastcall, __fastcall, __msfastcall
        //alias AR1 = "ECX";
        //alias AR2 = "EDX";
        //alias AR3 = "";
        //alias AR4 = "";
    }
    version(linux)
    {
        alias AR1 = "EDI";
        alias AR2 = "ESI";
        alias AR3 = "EDX";
        alias AR4 = "ECX";
        // R8, R9
    }

    alias M32 = uint;
    alias M64 = ulong;
    alias REG = M32;
}



extern(D):
alias X   = short;
alias Y   = short;
alias M32 = uint;
alias M64 = ulong;

version (x86)
alias M32 = uint;
extern(C)
struct PX
{
    M32 reg;  // XY
              // X.
              // .Y

    pragma(inline, true)
    auto get_y()
    {
        return reg & 0xFF;
        //movl    4(%esp), %eax
        //movzbl  (%eax), %eax
    }    

    pragma(inline, true)
    auto get_x()
    {
        return ( reg >> 16 ) & 0xFF;
        //movl    4(%esp), %eax
        //movzbl  2(%eax), %eax
    }
}

version (X86_64)
struct PX
{
    M64 reg;  // ..XY
              // ..X.
              // ...Y

    pragma(inline, true)
    auto get_y()
    {
        return reg & 0xFF;
        //movzbl  (%rdi), %eax
        //retq    
    }    

    pragma(inline, true)
    auto get_x()
    {
        return ( reg >> 16 ) & 0xFF;
        //movzbl  2(%rdi), %eax
        //retq
    }
}

import ldc.llvmasm;
import ldc.attributes;
pragma(inline, true)
nothrow @nogc @naked
M64 px_get_y( ref ulong px )
{
    pragma(LDC_allow_inline);
    return
        __asm!M64("
            movq  $1,   %rax
            and   $$0xFF, %rax
            movq  %rax,   $0
            ", 
            "=r,r",px
        );
}

void test( PX px )
{
    auto a = px_get_y( px.reg );
    a++;
}
