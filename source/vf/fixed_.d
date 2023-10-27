module vf.fixed_;


/*
import std.stdio;

alias M32 = int;
alias M16 = short;

// 16.16 Fixed Point Binary Type. 1.1 = 1 + 1/65536
// fix16_t
// fix16_16_t
struct Fixed_
{
    alias FRACBITS = 16;
    alias FRACUNIT = ( 1 << FRACBITS );

    M32 a;

    alias T = typeof(this);


    this( M32 a )
    {
        this.a = a;
    }


    this( Fixed_ fxd )
    {
        this.a = fxd.a;
    }


    T opBinary( string op : "+" )( T b )
    {
        return T( this.a + b.a );
    }


    T opBinary( string op : "-" )( T b )
    {
        return T( this.a + b.a );
    }


    T opBinary( string op : "*" )( T b )
    { // SHR, IMUL
        return 
            T( cast(M32)
                (
                    ( cast(long)a ) * 
                    ( cast(long)b )
                ) >> FRACBITS 
            );
    }


    T opBinary( string op : "*" )( M32 b )
    {
        return T( this.a * b );
    }


    T opBinary( string op : "/" )( T b )
    { // SHL, IDIV
        if ( (ABS( a ) >> 14 ) >= ABS( b ) )
        {
            return 
                (a^^b) < 0 ? 
                    M32.min : 
                    M32.max;
        }
        else
        {
            double c = 
                (cast(double)a) / (cast(double)b) * FRACUNIT;

            if ( c >= 2147483648.0 || c < -2147483648.0 )
                throw new Exception( "FixedDiv: divide by zero" );

            return T( cast(M32)c );
        }
            

        return 
            T( 
                cast(M32)( 
                    ( ( cast(long)(this.a) ) << 16 ) / b.a
                ) 
            );
    }

    T opBinary( string op : "/" )( M32 b )
    {
        return T( this.a / b );
    }

    int opCmp( Fixed_ b )
    {
        // a < b 
        if ( a == b.a )
            return 0;

        if ( a < b.a )
            return -1;

        else
            return 1;
    }


    M16 to_M16()
    {
        return cast(M16)( this.a >> FRACBITS );
    }


    M16 fraq_to_M16()
    {
        return cast(M16)( this.a & ( ( 1 << FRACBITS ) - 1) );
    }


    string toString()
    {
        import std.format;
        return format!"%s( %d . %d )"( typeof(this).stringof, to_M16(), fraq_to_M16() );
    }
}


auto ABS(T)(T a)
{
    return 
        ( a < 0 ) ? 
            (-a):
            ( a);
}

*/
