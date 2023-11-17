module vf.base.fixed;


struct Fixed
{
    int a;
    alias a this;

    this( int _int, int _fraq )
    {
        a = _int << 16  + _fraq;
    }

    this( int _fixed )
    {
        a = _fixed;
    }

    Fixed opBinary( string op : "+" )( Fixed b )
    {
        return Fixed( a + b.a );
    }

    int opCmp( Fixed b )
    {
        if ( a == b.a )
            return 0;

        if ( a > b.a )
            return 1;

        return -1;
    }

    string toString()
    {
        import std.format : format;
        return format!"%s(%d)"( typeof(this).stringof, a>>16 );
    }
}

