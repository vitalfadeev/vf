module vf.base.transformable;

import vf.base.sizeable   : SizeAble;
import vf.base.types      : M16;
import vf.base.fixed      : Fixed;


class TransformAble(Event,EventType,WX) : SizeAble!(Event,EventType,WX)
{
    Fixed   rotate;
    Fixed   scale;
    Ops     transformed_ops;
    Size    transformed_size;

    void transform()
    {
        //M matrix;
        //transformed_ops = ops.apply( matrix );
    }

    override
    void calc_size()
    {
        transformed_size = Size( transformed_ops.calc_size() );
    }
    
    override
    ref Size size()
    {
        return transformed_size;
    }
}

