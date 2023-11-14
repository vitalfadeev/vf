module vf.platforms.windows.element;

import vf.base.element;
import vf.event : Event, EVENT_TYPE;
import vf.wx    : WX;

alias Element = vf.base.element.Element!(Event, EVENT_TYPE,WX);
