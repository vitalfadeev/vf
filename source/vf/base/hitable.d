module vf.base.hitable;

import vf.base.wxable   : WxAble;


class HitAble(Event,EventType,WX) : WxAble!(Event,EventType,WX)
{
    alias THIS    = typeof(this);
    alias HitAble = typeof(this);

    bool hit_test( WX wx )
    {
        return ( this.wx == wx );
    }
}
