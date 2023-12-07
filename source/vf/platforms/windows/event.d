module vf.platforms.windows.la;

version(WINDOWS):
import core.sys.windows.windows;
import vf.base.la;
import vf.interfaces : ISensAble;


struct La
{
    union {
        MSG       msg;
        DrawLa draw;
    }

    auto type()
    {
        return msg.message;
    }

    auto dst()
    {
        //return cast( ISensAble )( msg.hwnd );
        return cast( ISensAble )null;
    }
}

alias LaType = typeof(MSG.message);

enum VF_DRAW = WM_PAINT;

import vf.interfaces : IDrawAble;
struct DrawLa
{
    LaType type = VF_DRAW;
    IDrawAble drawable;
}

