module vf.drawable;

import vf.base.drawable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.event : Event, EVENT_TYPE;

version(XCB)
import vf.platforms.xcb.event : Event, EVENT_TYPE;

alias DrawAble = vf.base.drawable.DrawAble!(Event,EVENT_TYPE,WX);
