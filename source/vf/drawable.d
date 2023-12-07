module vf.drawable;

import vf.base.drawable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.la : La, LaType;

version(XCB)
import vf.platforms.xcb.la : La, LaType;

alias DrawAble = vf.base.drawable.DrawAble!(La,LaType,WX);
