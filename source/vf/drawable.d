module vf.drawable;

import vf.base.drawable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.event : Event, EventType;

version(XCB)
import vf.platforms.xcb.event : Event, EventType;

alias DrawAble = vf.base.drawable.DrawAble!(Event,EventType,WX);
