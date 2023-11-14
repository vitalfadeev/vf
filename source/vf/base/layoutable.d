module vf.base.layoutable;

import vf.base.drawable : DrawAble;
import vf.base.wx       : WX;


enum SIZE_MODE
{
    OUTER = 1,
    FIXED = 2,
    INTER = 3,
}

class LayoutAble(Event,EVENT_TYPE) : DrawAble!(Event,EVENT_TYPE)
{
    WX _wh;
    SIZE_MODE size_mode;

    void calc_wh( LayoutAble parent )
    {
        _wh = ops.calc_wh();
    }

    auto wh()
    {
        return _wh;
    }
}
