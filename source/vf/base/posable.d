module vf.base.posable;

import vf.base.transformable : TransformAble;

WX;
RX;


class 
PosAble : TransformAble {
    alias THIS       = typeof(this);
    alias LayoutAble = typeof(this);

    Pos pos;


    bool 
    at (WX wx) {
        return pos.wx == wx;
    }


    struct 
    Pos {
        WX wx;  // world
        RX rx;  // relative
    }
}
