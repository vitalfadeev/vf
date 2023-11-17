module vf.platforms.windows.element;

import vf.base.element;
import vf.event : Event, EventType;
import vf.wx    : WX;

alias Element = vf.base.element.Element!(Event, EventType,WX);
