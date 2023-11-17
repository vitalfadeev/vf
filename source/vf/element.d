module vf.element;

import vf.base.enterable : EnterAble;
import vf.event          : Event, EventType;
import vf.wx             : WX;
 
alias Element = EnterAble!(Event,EventType,WX);
