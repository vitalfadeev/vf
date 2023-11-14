module vf.transformable;

import vf.base.transformable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.event : Event, EVENT_TYPE;

version(XCB)
import vf.platforms.xcb.event : Event, EVENT_TYPE;

alias TransformAble = vf.base.transformable.TransformAble!(Event,EVENT_TYPE,WX);
