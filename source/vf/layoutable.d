module vf.layoutable;

import vf.base.layoutable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.la : La, LaType;

version(XCB)
import vf.platforms.xcb.la : La, LaType;

alias LayoutAble = vf.base.layoutable.LayoutAble!(La,LaType,WX);
