module vf.base.layoutable;

import vf.base.transformable : TransformAble;


class LayoutAble(Event,EventType,WX) : TransformAble!(Event,EventType,WX)
{
    Pos!WX pos;
}


struct Pos(WX)
{
    WX wx;
}
