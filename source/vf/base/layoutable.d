module vf.base.layoutable;

import vf.base.transformable : TransformAble;


class LayoutAble(Event,EVENT_TYPE,WX) : TransformAble!(Event,EVENT_TYPE,WX)
{
    Pos!WX pos;
}


struct Pos(WX)
{
    WX wx;
}
