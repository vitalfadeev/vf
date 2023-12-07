module vf.base.layoutable;

import vf.base.posable : PosAble;


class LayoutAble(La,LaType,WX) : PosAble!(La,LaType,WX)
{
    alias THIS       = typeof(this);
    alias LayoutAble = typeof(this);

    void layout()
    {
        //
    }
}
