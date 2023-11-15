module vf.base.transformable;

import vf.base.drawable   : Ops;
import vf.base.layoutable : LayoutAble;
import vf.base.types      : M16;
import vf.base.fixed      : Fixed;


class TransformAble(Event,EVENT_TYPE,WX) : LayoutAble!(Event,EVENT_TYPE,WX)
{
    Fixed  rotate;
    Fixed  scale;
    Ops!WX transformed_ops;
    WX     transformed_wh;

    void transform()
    {
        //M matrix;
        //transformed_ops = ops.apply( matrix );
    }

    override
    void calc_wh( LayoutAble!(Event,EVENT_TYPE,WX) outer )
    {
        transformed_wh = WX( transformed_ops.calc_wh() );
    }
    
    override
    ref WX wh()
    {
        return transformed_wh;
    }
}

