module vf.element;

import vf.base.enterable : EnterAble;
import vf.event          : Event, EVENT_TYPE;
import vf.wx             : WX;
 
alias Element = EnterAble!(Event,EVENT_TYPE,WX);
