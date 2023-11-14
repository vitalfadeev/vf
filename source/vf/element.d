module vf.element;

import vf.base.enterable;
import vf.wx : WX;

version(Windows)
import vf.platforms.windows.event : Event, EVENT_TYPE;

version(XCB)
import vf.platforms.xcb.event : Event, EVENT_TYPE;


alias Element = vf.base.enterable.EnterAble!(Event,EVENT_TYPE,WX);
