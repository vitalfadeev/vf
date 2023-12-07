module vf.base.wxable;

import vf.base.sensable : SensAble;


class WxAble(La,LaType,TWX) : SensAble!(La,LaType)
{
    alias THIS   = typeof(this);
    alias WxAble = typeof(this);
    alias WX   = TWX;

    WX wx;  // center of this, in World coordinates
}
