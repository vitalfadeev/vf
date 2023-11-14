


//
void update_sizes( Element e )
{
    e.each_recursive( &e.calc_wh );
}

void MAX(T)( T a, ref T b )
{
    if ( a > b )
        return b = a;
}
