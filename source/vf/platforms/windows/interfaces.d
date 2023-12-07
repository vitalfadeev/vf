module vf.platforms.windows.interfaces;

version(WINDOWS):
import core.sys.windows.windows;
import vf.base.interfaces;
import vf.la : La, LaType;

alias ISensAble      = vf.base.interfaces.ISensAble!(La,LaType);
alias IWindow        = vf.base.interfaces.IWindow!(La,LaType);
alias IHitAble       = vf.base.interfaces.IHitAble;
alias IWindowManager = vf.base.interfaces.IWindowManager!(IWindow,HWND);
alias IDrawAble      = vf.base.interfaces.IDrawAble;
alias IEnterAble     = vf.base.interfaces.IEnterAble;
