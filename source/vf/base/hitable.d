module vf.base.hitable;

import vf.base.wxable   : WxAble;


class HitAble(Event,EventType,WX) : WxAble!(Event,EventType,WX)
{
    bool hit_test( WX wx )
    {
        return ( this.wx == wx );
    }
}
