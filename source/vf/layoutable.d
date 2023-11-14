module vf.layoutable;

import vf.base.layoutable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.event : Event, EVENT_TYPE;

version(XCB)
import vf.platforms.xcb.event : Event, EVENT_TYPE;

alias LayoutAble = vf.base.layoutable.LayoutAble!(Event,EVENT_TYPE,WX);
