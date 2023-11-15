module vf.base.transformable;

import vf.base.drawable   : Ops;
import vf.base.sizeable   : SizeAble;
import vf.base.types      : M16;
import vf.base.fixed      : Fixed;
import vf.base.sizeable   : Size;


class TransformAble(Event,EVENT_TYPE,WX) : SizeAble!(Event,EVENT_TYPE,WX)
{
    Fixed   rotate;
    Fixed   scale;
    Ops!WX  transformed_ops;
    Size!WX transformed_size;

    void transform()
    {
        //M matrix;
        //transformed_ops = ops.apply( matrix );
    }

    override
    void calc_size()
    {
        transformed_size = Size!WX( transformed_ops.calc_size() );
    }
    
    override
    ref Size!WX size()
    {
        return transformed_size;
    }
}

