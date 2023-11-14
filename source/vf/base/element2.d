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

class Layoutable : DrawAble
{
    WX _wh;
    SIZE_MODE size_mode;

    void calc_wh( Layoutable parent )
    {
        _wh = ops.calc_wh();
    }

    auto wh()
    {
        return _wh;
    }
}

class Transformable : Layoutable
{
    Fixed rotate;
    Fixed scale;
    Ops   transformed_ops;
    WX    transformed_wh;

    void transform()
    {
        transformed_ops = ops.apply( matrix );
    }

    override
    void calc_wh()
    {
        transformed_wh = transformed_ops.calc_wh();
    }
    
    override
    auto wh()
    {
        return transformed_wh;
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

    override
    void sense( Event* event, EVENT_TYPE event_type )
    {
        super.sense( event, event_type );

        foreach ( e; enter )
            e.sense( event, event_type );
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

    void apply(M)( M matrix )
    {
        foreach ( op; ops )
            op.apply( matrix );
    }
}

struct Op
{
    WX calc_wh();
    void apply( M matrix );
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
