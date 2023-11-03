module vf.platforms.windows.interfaces;

version(WINDOWS):
import core.sys.windows.windows;
import vf.event : Event, EVENT_TYPE;
import vf.base.interfaces;

alias ISensAble      = vf.base.interfaces.ISensAble!(Event,EVENT_TYPE);
alias IWindow        = vf.base.interfaces.IWindow!(Event,EVENT_TYPE);
alias IHitAble       = vf.base.interfaces.IHitAble;
alias IWindowManager = vf.base.interfaces.IWindowManager!(IWindow,HWND);
alias IDrawAble      = vf.base.interfaces.IDrawAble;
alias IEnterAble     = vf.base.interfaces.IEnterAble;
