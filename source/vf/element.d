module vf.element;

import vf.base.enterable : EnterAble;
import vf.la          : La,LaType;
import vf.wx             : WX;
 
alias Element = EnterAble!(La,LaType,WX);
