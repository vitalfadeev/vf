module vf.base.hitable;

import vf.base.wxable   : WxAble;


class HitAble(La,LaType,WX) : WxAble!(La,LaType,WX)
{
    alias THIS    = typeof(this);
    alias HitAble = typeof(this);

    bool hit_test( WX wx )
    {
        return ( this.wx == wx );
    }
}
