module vf.platforms.xcb.element;

import vf.base.element;
import vf.platforms.xcb.la : La, LaType;
import vf.platforms.xcb.wx    : WX;

alias Element = vf.base.element.Element!(La,LaType,WX);
