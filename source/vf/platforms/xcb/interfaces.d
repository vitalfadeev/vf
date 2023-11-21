module vf.platforms.xcb.interfaces;

version(XCB):
import xcb.xcb;
import vf.base.interfaces;
import vf.input.event : Event,EventType;

alias ISensAble      = vf.base.interfaces.ISensAble!(Event,EventType);
alias IWindow        = vf.base.interfaces.IWindow!(Event,EventType);
alias IHitAble       = vf.base.interfaces.IHitAble;
alias IWindowManager = vf.base.interfaces.IWindowManager!(IWindow,xcb_generic_event_t);
alias IDrawAble      = vf.base.interfaces.IDrawAble;
alias IEnterAble     = vf.base.interfaces.IEnterAble;
