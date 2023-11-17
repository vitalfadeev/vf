module vf.base.fixed;


struct Fixed
{
    int a;
    alias a this;

    this( int _int, int _fraq )
    {
        a = _int << 16  + _fraq;
    }

    int opCmp( Fixed b )
    {
        if ( a == b.a )
            return 0;

        if ( a > b.a )
            return 1;

        return -1;
    }
}

