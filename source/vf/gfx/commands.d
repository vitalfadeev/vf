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
alias DQWORD = ucent ;  // 128

alias M8     = BYTE  ;  //   8
alias M16    = WORD  ;  //  16
alias M32    = DWORD ;  //  32
alias M64    = QWORD ;  //  64
alias M128   = DQWORD;  // 128

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

struct PointGFXI
{
    GFXI_CODE code = GFXI_CODE.POINT;
    PX px;
}

struct LineGFXI
{
    GFXI_CODE code = GFXI_CODE.LINE;
    PX px;
}

struct ColorGFXI
{
    GFXI_CODE code = GFXI_CODE.LINE;
    COLOR color;
}

enum GFXI_CODE
{
    _,
    POINT,
    LINE,
    COLOR,
}


struct Queue
{
    GFXI a;
}


struct Pixels
{
    Color* a;
    int    pitch;

    void opOpAssign( string op : "+" )( PX px )
    {
        a = ( a + px.y * pitch ) + ( a + px.x );
    }
}


void render( Queue queue, Pixels pixels )
{
    foreach( gfxi; queue )
    {
        final
        switch ( gfxi.code )
        {
            case GFXI_CODE._    : { break; };
            case GFXI_CODE.POINT: { point( pixels, gfxi.point ); break; };
            case GFXI_CODE.LINE : { line ( pixels, gfxi.line  ); break; };
            case GFXI_CODE.COLOR: { color( pixels, gfxi.color ); break; };
        }
    }
}

pragma( inline, true )
void point( Pixels pixels, PointGFXI point )
{
    pixels += point.px;
    *pixels = pixels.color;
}

pragma( inline, true )
void line( Pixels pixels, LineGFXI line )
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
void color( Pixels pixels, ColorGFXI color )
{
    pixels.color = color.color;
}


pragma( inline, true )
auto is_h( LineGFXI line )
{
    return line.px.y == 0;
}

pragma( inline, true )
auto is_v( LineGFXI line )
{
    return line.px.x == 0;
}

pragma( inline, true )
auto is_d( LineGFXI line )
{
    return line.px.x != 0 && line.px.y != 0;
}


pragma( inline, true )
void h_line( Pixels pixels, LineGFXI line )
{
    auto _count = ABS(line.px.x);
    auto _dst   = pixels.a;
    auto _color = pixels.color;

    if ( _count == 0 )
        return;

    while (1)
    {
        *_dst = _color;

        _count--;
        if ( _count == 0 )
            break;

        _dst++;
    }

    pixels.a = _dst-1;
}

pragma( inline, true )
void v_line( Pixels pixels, LineGFXI line )
{
    auto _count = ABS(line.px.y);
    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _pitch = pixels.pitch;

    if ( _count == 0 )
        return;

    while (1)
    {
        *_dst = _color;

        _count--;
        if ( _count == 0 )
            break;

        _dst += _pitch;
    }

    pixels.a = _dst - _pitch;
}

pragma( inline, true )
void d_line( Pixels pixels, LineGFXI line )
{
    if ( line.px.x = line.px.y )
        d_line_45();
    else
    if ( line.px.x > line.px.y )
        d_line_30();
    else
        d_line_60();
}


pragma( inline, true )
void d_line_45( Pixels pixels, LineGFXI line )
{
    auto x = line.px.x;
    auto y = line.px.y;

    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _count = ABS(x);

    auto _x_inc = color.sizeof;
    auto _y_inc = pixels.pitch;

    if ( _count == 0 )
        return;

    while (1)
    {
        *_dst = _color;

        _count--;
        if ( _count == 0 )
            break;

        _dst += _x_inc + _y_inc;
    }
}

pragma( inline, true )
void d_line_30( Pixels pixels, LineGFXI line )
{
    auto x = line.px.x;
    auto y = line.px.y;

    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _count = ABS(x);

    auto _x_inc = color.sizeof;
    auto _y_inc = pixels.pitch;

    auto _fraq_base = x/y;
    auto _fraq      = _fraq_base;

    if ( _count == 0 )
        return;

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
void d_line_60( Pixels pixels, LineGFXI line )
{
    auto x = line.px.x;
    auto y = line.px.y;

    auto _dst   = pixels.a;
    auto _color = pixels.color;
    auto _count = ABS(x);

    auto _x_inc = color.sizeof;
    auto _y_inc = pixels.pitch;

    auto _fraq_base = y/x;
    auto _fraq      = _fraq_base;

    if ( _count == 0 )
        return;

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

auto ABS(T)(T a)
{
    return 
        ( a < 0 ) ? 
            (-a):
            ( a);
}

