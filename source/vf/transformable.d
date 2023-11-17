module vf.transformable;

import vf.base.transformable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.event : Event, EventType;

version(XCB)
import vf.platforms.xcb.event : Event, EventType;

alias TransformAble = vf.base.transformable.TransformAble!(Event,EventType,WX);
