module vf.base.wxable;

import vf.base.sensable : SensAble;


class WxAble(Event,EventType,TWX) : SensAble!(Event,EventType)
{
    alias THIS = typeof(this);
    alias WX   = TWX;

    WX wx;  // center of this, in World coordinates
}
