module vf.base.layoutable;

import vf.base.drawable : DrawAble;


enum SIZE_MODE
{
    OUTER = 1,
    FIXED = 2,
    INTER = 3,
}

class LayoutAble(Event,EVENT_TYPE,WX) : DrawAble!(Event,EVENT_TYPE,WX)
{
    WX _wh;
    SIZE_MODE size_mode;

    void calc_wh( LayoutAble!(Event,EVENT_TYPE,WX) outer )
    {
        _wh = ops.calc_wh();
    }

    ref WX wh()
    {
        return _wh;
    }
}

//
void update_sizes(Event,EVENT_TYPE,WX)( LayoutAble!(Event,EVENT_TYPE,WX) e )
{
    e.each_recursive( &e.calc_wh );
}

