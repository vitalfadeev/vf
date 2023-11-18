module vf.base.layoutable;

import vf.base.transformable : TransformAble;


class LayoutAble(Event,EventType,WX) : TransformAble!(Event,EventType,WX)
{
    alias THIS       = typeof(this);
    alias LayoutAble = typeof(this);

    Pos pos;

    void layout()
    {
        //
    }

    struct Pos
    {
        WX wx;
    }
}
