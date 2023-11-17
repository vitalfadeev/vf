module vf.layoutable;

import vf.base.layoutable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.event : Event, EventType;

version(XCB)
import vf.platforms.xcb.event : Event, EventType;

alias LayoutAble = vf.base.layoutable.LayoutAble!(Event,EventType,WX);
