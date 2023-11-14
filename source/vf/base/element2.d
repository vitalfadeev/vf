module vf.base.element;


class _Sensable(Event,EVENT_TYPE)
{
    void sense( Event* event, EVENT_TYPE event_type )
    {
        //
    }
}
version(Windows)
alias Sensable = _Sensable!(Event,EVENT_TYPE);


class DrawAble : Sensable
{
    Ops ops;
}


enum SIZE_MODE
{
    OUTER = 1,
    FIXED = 2,
    INTER = 3,
}

class Transformable : DrawAble
{
    Fixed rotate;
    Fixed scale;

    void transform()
    {
        // ops.apply( matrix );
    }
}

class Layoutable : Transformable
{
    WX wh;
    SIZE_MODE size_mode;

    void calc_wh( Layoutable parent )
    {
        wh = ops.calc_wh();
    }
}

class Enterable : Layoutable
{
    Enter enter;

    void each( void delegate( Enterable e ) dg )
    {
        foreach ( e; enter )
            dg( e );
    }

    void each_recursive( void delegate( Enterable e ) dg )
    {
        foreach ( e; enter )
        {
            dg( e );
            e.each_recursive( dg );
        }
    }

    override
    void calc_wh( Enterable outer_ )
    {
        final
        switch ( size_mode )
        {
            case OUTER: wh = outer_.wh; break;
            case FIXED: super.calc_wh(); break;
            case INTER: wh = enter.wh; break;
        }
    }
}

alias Element = Enterable;


//
void update_sizes( Element e )
{
    e.each_recursive( &e.calc_wh );
}

struct Fixed
{
    int a;
}

struct WX
{
    Fixed x;
    Fixed y;
}

void MAX(T)( T a, ref T b )
{
    if ( a > b )
        return b = a;
}

struct Ops
{
    Op[] ops;

    void calc_wh()
    {
        typeof(WX.x) max_x;
        typeof(WX.y) max_y;

        foreach ( op; ops )
        {
            UPD_MAX( op.max_x, max_x );
            UPD_MAX( op.max_y, max_y );
        }

        return tuple!("x","y")( max_x, max_y );
    }    
}

struct Enter
{
    Enterable[] arr;

    auto wh()
    {
        typeof(Layoutable.wh) wh;

        foreach ( e; arr )
        {
            e.calc_wh();
            wh += e.wh;
        }

        return wh;
    }
}
