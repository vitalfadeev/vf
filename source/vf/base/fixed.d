module vf.base.fixed;


struct Fixed
{
    int a;
    alias a this;

    int opCmp( Fixed b )
    {
        if ( a == b.a )
            return 0;

        if ( a > b.a )
            return 1;

        return -1;
    }
}

