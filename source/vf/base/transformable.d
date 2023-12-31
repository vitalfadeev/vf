module vf.base.transformable;

import vf.base.sizeable   : SizeAble;
import vf.base.fixed      : Fixed;


class TransformAble(La,LaType,WX) : SizeAble!(La,LaType,WX)
{
    alias THIS          = typeof(this);
    alias TransformAble = typeof(this);

    Fixed   rotate;
    Fixed   scale;
    Ops     transformed_ops;
    Size    transformed_size;

    void transform()
    {
        //M matrix;
        //transformed_ops = ops.apply( matrix );
        transformed_ops = ops.dup;
    }

    //override
    //void calc_size()
    //{
    //    transformed_size = Size( transformed_ops.calc_size() );
    //}
    //
    //override
    //ref Size size()
    //{
    //    return transformed_size;
    //}
}

