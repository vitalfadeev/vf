module vf.platforms.windows.event;

version(WINDOWS):
import core.sys.windows.windows;
import vf.interfaces : ISensAble;


struct Event
{
    union {
        MSG       msg;
        DrawEvent draw;
    }

    auto type()
    {
        return msg.message;
    }

    auto dst()
    {
        return cast( ISensAble )( msg.hwnd );
    }
}

alias EVENT_TYPE = typeof(MSG.message);

enum VF_DRAW = WM_PAINT;

import vf.interfaces : IDrawAble;
struct DrawEvent
{
    EVENT_TYPE type = VF_DRAW;
    IDrawAble drawable;
}

