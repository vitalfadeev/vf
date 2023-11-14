module vf.base.transformable;

import vf.base.drawable   : Ops;
import vf.base.layoutable : LayoutAble;
import vf.base.types      : M16;
import vf.base.wx         : WX;
import vf.base.fixed      : Fixed;


class TransformAble(Event,EVENT_TYPE) : LayoutAble!(Event,EVENT_TYPE)
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

