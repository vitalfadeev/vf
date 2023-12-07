module vf.transformable;

import vf.base.transformable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.la : La, LaType;

version(XCB)
import vf.platforms.xcb.la : La, LaType;

alias TransformAble = vf.base.transformable.TransformAble!(La,LaType,WX);
