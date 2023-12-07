module vf.platforms.xcb.interfaces;

version(XCB):
import xcb.xcb;
import vf.base.interfaces;
import vf.input.la : La,LaType;

alias ISensAble      = vf.base.interfaces.ISensAble!(La,LaType);
alias IWindow        = vf.base.interfaces.IWindow!(La,LaType);
alias IHitAble       = vf.base.interfaces.IHitAble;
alias IWindowManager = vf.base.interfaces.IWindowManager!(IWindow,xcb_generic_la_t);
alias IDrawAble      = vf.base.interfaces.IDrawAble;
alias IEnterAble     = vf.base.interfaces.IEnterAble;
