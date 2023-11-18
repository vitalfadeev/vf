module vf.platforms.xcb.element;

import vf.base.element;
import vf.platforms.xcb.event : Event, EventType;
import vf.platforms.xcb.wx    : WX;

alias Element = vf.base.element.Element!(Event,EventType,WX);
