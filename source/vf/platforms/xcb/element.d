module vf.platforms.xcb.element;

import vf.base.element;
import vf.event : Event, EVENT_TYPE;

alias Element      = vf.base.element.Element!(Event, EVENT_TYPE);
alias EnterElement = vf.base.element.EnterElement!(Event, EVENT_TYPE);
