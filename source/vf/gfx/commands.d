module vf.gfx.commands;


// Instruction
// Queue
// Decode
//
// Rename/Alloc
// Scheduler
// Core  Core  Core

// based on Intel x86 Architeture Manual
alias BYTE   = ubyte ;  //   8
alias WORD   = ushort;  //  16
alias DWORD  = uint  ;  //  32
alias QWORD  = ulong ;  //  64
//alias DQWORD = core.int128.Cent ;  // 128

alias M8     = BYTE  ;  //   8
alias M16    = WORD  ;  //  16
alias M32    = DWORD ;  //  32
alias M64    = QWORD ;  //  64
//alias M128   = DQWORD;  // 128

// POINTER
alias PTR    = void*;   // 64 on x86_64, 32 on x86

// STRING
alias BIT_STRING  = void*;
alias BYTE_STRING = BYTE*;

// SIMD
alias PACKED_BYTES  = BYTE[8];  // 64 bit
alias PACKED_WORDS  = WORD[4];  // 64 bit
alias PACKED_DWORDS = DWORD[2]; // 64 bit

alias DPACKED_BYTES  = BYTE[16];  // 128 bit
alias DPACKED_WORDS  = WORD[8];   // 128 bit
alias DPACKED_DWORDS = DWORD[4];  // 128 bit
alias DPACKED_QWORDS = QWORD[2];  // 128 bit


// GFX instructions
struct GFXI
{
    union
    {
        GFXI_CODE code;
        PointGFXI point;
        LineGFXI  line;
        ColorGFXI color;
    }
    GFXI* next;
}

struct PX
{
    short x;
    short y;
}

alias Color = uint;

struct PointGFXI
{
    GFXI_CODE code = GFXI_CODE.POINT;
    PX px;
}

struct LineGFXI
{
    GFXI_CODE code = GFXI_CODE.LINE;
    PX dxdy;
}

struct ColorGFXI
{
    GFXI_CODE code = GFXI_CODE.LINE;
    Color color;
}

enum GFXI_CODE
{
    _,
    POINT,
    LINE,
    COLOR,
}


//alias Queue = queue.Queue!GFXI;
alias Queue = GrowableCircularQueue!GFXI;

struct GrowableCircularQueue(T) {
    public size_t length;
    private size_t first, last;
    private T[] A = [T.init];

    this(T[] items...) pure nothrow @safe {
        foreach (x; items)
            push(x);
    }

    @property bool empty() const pure nothrow @safe @nogc {
        return length == 0;
    }

    @property T front() pure nothrow @safe @nogc {
        assert(length != 0);
        return A[first];
    }

    T opIndex(in size_t i) pure nothrow @safe @nogc {
        assert(i < length);
        return A[(first + i) & (A.length - 1)];
    }

    void push(T item) pure nothrow @safe {
        if (length >= A.length) { // Double the queue.
            immutable oldALen = A.length;
            A.length *= 2;
            if (last < first) {
                A[oldALen .. oldALen + last + 1] = A[0 .. last + 1];
                static if (hasIndirections!T)
                    A[0 .. last + 1] = T.init; // Help for the GC.
                last += oldALen;
            }
        }
        last = (last + 1) & (A.length - 1);
        A[last] = item;
        length++;
    }

    @property T pop() pure nothrow @safe @nogc {
        assert(length != 0);
        auto saved = A[first];
        static if (hasIndirections!T)
            A[first] = T.init; // Help for the GC.
        first = (first + 1) & (A.length - 1);
        length--;
        return saved;
    }
}


struct Pixels
{
    Color* a;
    PX     size;
    Color  color;

    void opOpAssign( string op : "+" )( PX px )
    {
        a = ( a + px.y * pitch ) + ( a + px.x );
    }
}


version(stub)
version(X86_64)
version(Win64)
void render( Queue queue, void* stub, Pixels* pixels )
//                 RDI          RSI           RDX
{
    //
}

// default
static if ( !is( typeof( .render ) ) )
pragma( inline, true )
void render( Queue queue, void* stub, Pixels* pixels )
//                 RDI          RSI           RDX
{
    Queue queue = new Queue;

    queue.put( PointGFXI( GFXI_CODE.POINT, PX( 100, 100 ) ) );
    queue.put( PointGFXI( GFXI_CODE.POINT, PX( 101, 100 ) ) );
    queue.put( PointGFXI( GFXI_CODE.POINT, PX( 102, 100 ) ) );
    queue.put( PointGFXI( GFXI_CODE.POINT, PX( 103, 100 ) ) );
    queue.put( PointGFXI( GFXI_CODE.POINT, PX( 104, 100 ) ) );

    foreach( gfxi; queue )
        render_one( gfxi.code, &gfxi );
}

pragma( inline, true )
void render_one( GFXI_CODE gfxi_code, GFXI* gfxi, Pixels* pixels )
//                    RDI              RSI           RDX
{
    final
    switch ( gfxi_code )  // auto-optomized by DMD, LDC to jmp-table
    {
        case GFXI_CODE._    : { break; }
        case GFXI_CODE.POINT: { point( gfxi_code, cast(PointGFXI*)gfxi, pixels ); break; }
        case GFXI_CODE.LINE : { line ( gfxi_code, cast(LineGFXI* )gfxi, pixels ); break; }
        case GFXI_CODE.COLOR: { color( gfxi_code, cast(colorGFXI*)gfxi, pixels ); break; }
    }
}

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
version(Win64)
pragma( inline, true )
void point( GFXI_CODE gfxi_code, PointGFXI* point, Pixels* pixels )
{
    // EDI = current
    // EAX = color
    // ECX = count // w for h_line, h for v_line
    // ... = _x_inc
    // ESI = _y_inc

    asm
    {
        naked;
        mov dword ptr [RDI], EAX;
    }
}

// default
static if ( !is( typeof( .point ) ) )
pragma( inline, true )
void point( GFXI_CODE gfxi_code, PointGFXI* point, Pixels* pixels )
{
    pixels += point.px;
    *pixels = pixels.color;
}


pragma( inline, true )
void line( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
{
    if ( line.is_h )
        h_line( pixels, line );
    else
    if ( line.is_v )
        v_line( pixels, line );
    else
        d_line( pixels, line );
}


pragma( inline, true )
void color( GFXI_CODE gfxi_code, ColorGFXI* color, Pixels* pixels )
{
    pixels.color = color.color;
}


pragma( inline, true )
auto is_h( LineGFXI line )
{
    return line.dxdy.y == 0;
}

pragma( inline, true )
auto is_v( LineGFXI line )
{
    return line.dxdy.x == 0;
}

pragma( inline, true )
auto is_d( LineGFXI line )
{
    return line.dxdy.x != 0 && line.dxdy.y != 0;
}


version(stub)
version(X86_64)
version(Win64)
pragma( inline, true )
void h_line( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
//                     RDI                  RSI           RDX
{
    // RDX = pixels.a
    // EAX = pixels.color
    // RCX = line.dxdy // w for h_line, h for v_line. + to right, - to left
    //     
/*
    asm
    {
        naked          ;

        test  RCX, RCX ;# if count < 0
        js    TO_LEFT  ;#   left
                        # else 
    TO_RIGHT:          ;#   right
        cld            ;#   
        jmp   LOOP     ;#

    TO_LEFT:            # left
        std            ;#   left
        neg   RCX      ;#   ABS(x)

    LOOP:              ;#
        rep            ;#
        stosd          ;#  for 0..count: *current = color
    }
*/
}

// default
static if ( !is( typeof( .h_line ) ) )
pragma( inline, true )
void h_line( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
{
    auto _count = line.dxdy.x;

    if ( _count == 0 )
        return;

    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _x_inc = 1;

    if ( _count < 0 )
    {
        _count = -_count;
        _x_inc = -_x_inc;
    }

    while (1)
    {
        *_dst = _color;

        _count--;
        if ( _count == 0 )
            break;

        _dst += _x_inc;
    }

    pixels.a = _dst - _x_inc;
}

version(stub)
version(X86_64)
version(Win64)
pragma( inline, true )
void v_line( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
//                     RDI                  RSI           RDX
{
    // EDI = current
    // EAX = color
    // ECX = count // w for h_line, h for v_line. + to down, - to up
    // ... = _x_inc
    // ESI = _y_inc
    //
    // EDX = _inc =
    //   (count >= 0) ? 
    //     _y_inc : 
    //    -_y_inc
/*
    asm
    {
        naked           ;

        mov   RDX, RSI  ;# _inc = _y_inc

        test  RCX, RCX  ;# if count >= 0
        jns   V_LOOP    ;#   _inc
        neg   RDX       ;# else 
        neg   RCX       ;#   -count
                        ;#   -_inc
    V_LOOP:             ;#
        mov   dword ptr [RDI], EAX;  # *current = color
        add   RDI, RDX  ; current += _inc
        dec   RCX       ; count--
        jnz   V_LOOP    ; if count != 0 continue
    }
*/
}

// default
static if ( !is( typeof( .v_line ) ) )
pragma( inline, true )
void v_line( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
{
    auto _count = line.dxdy.y;

    if ( _count == 0 )
        return;

    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _y_inc = pixels.size.w;

    if ( _count < 0 )
    {
        _count = -_count;
        _y_inc = -_y_inc;
    }

    while (1)
    {
        *_dst = _color;

        _count--;
        if ( _count == 0 )
            break;

        _dst += _y_inc;
    }

    pixels.a = _dst - _y_inc;
}

pragma( inline, true )
void d_line( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
{
    if ( line.px.x = line.px.y )
        d_line_45();
    else
    if ( line.px.x > line.px.y )
        d_line_30();
    else
        d_line_60();
}


version(stub)
version(X86_64)
version(Win64)
pragma( inline, true )
void d_line_45( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
//                        RDI                  RSI           RDX
{
    // EDI = current
    // EAX = color
    // ECX = count // w for h_line, h for v_line. + to down, - to up
    //       xy
    // ... = _x_inc
    // ESI = _y_inc
    //
    // EDX = _inc
    //   _inc = 
    //     (dx >= 0) && (dy >= 0):  _x_inc + _y_inc 
    //     (dx >= 0) && (dy <  0):  _x_inc - _y_inc 
    //     (dx <  0) && (dy >= 0): -_x_inc + _y_inc 
    //     (dx <  0) && (dy <  0): -_x_inc - _y_inc 
/*
    asm
    {
        naked           ;

        mov   RDX, RSI  ;# _inc = _y_inc

        test  RCX, RCX  ;# if count >= 0
        jns   D_LOOP    ;#   _inc
        neg   RDX       ;# else 
        neg   RCX       ;#   -count
                        ;#   -_inc
    D_LOOP:             ;#
        mov   dword ptr [RDI], EAX;  # *current = color
        add   RDI, RDX  ; current += _inc
        dec   RCX       ; count--
        jnz   V_LOOP    ; if count != 0 continue
    }
*/
}

// default
static if ( !is( typeof( .d_line_45 ) ) )
pragma( inline, true )
void d_line_45( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
{
    auto _x = line.dxdy.x;
    auto _y = line.dxdy.y;

    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _count = _x;

    auto _x_inc = 1;
    auto _y_inc = pixels.size.w;

    if ( _count == 0 )
        return;

    if ( _count < 0 )
        _x_inc = -_x_inc;

    if ( _y < 0 )
        _y_inc = -_y_inc;

    auto _inc = _x_inc + _y_inc;

    while (1)
    {
        *_dst = _color;

        _count--;
        if ( _count == 0 )
            break;

        _dst += _inc;
    }

    _dst -= _inc;
}

pragma( inline, true )
void d_line_30( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
{
    auto _x = line.dxdy.x;
    auto _y = line.dxdy.y;

    auto _count = _x;

    if ( _count == 0 )
        return;

    auto _dst   = pixels.a;
    auto _color = pixels.color;

    auto _x_inc = 1;
    auto _y_inc = pixels.size.w;

    auto _fraq_base = _x/_y;
    if ( _fraq_base < 0 )
        _fraq_base = -_fraq_base;

    auto _fraq = _fraq_base;

    if ( _count < 0 )
    {
        _count = - _count;
        _x_inc = -_x_inc;
    }

    if ( _y < 0 )
        _y_inc = -_y_inc;

    while (1)
    {
        *_dst = _color;

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

pragma( inline, true )
void d_line_60( GFXI_CODE gfxi_code, LineGFXI* line, Pixels* pixels )
{
    auto _x = line.dx.x;
    auto _y = line.dx.y;

    auto _count = _x;

    if ( _count == 0 )
        return;

    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _x_inc = 1;
    auto _y_inc = pixels.size.w;

    auto _fraq_base = y/x;
    if ( _fraq_base < 0 )
        _fraq_base = -_fraq_base;

    auto _fraq = _fraq_base;

    if ( _count < 0 )
    {
        _count = - _count;
        _x_inc = -_x_inc;
    }

    if ( _y < 0 )
        _y_inc = -_y_inc;

    while (1)
    {
        *_dst = _color;

        _count--;
        if ( _count == 0 )
            break;

        _fraq--;
        if ( _fraq == 0 )
        {
            _dst += _x_inc;
            _fraq = _fraq_base;
        }

        _dst += _y_inc;
    }
}
