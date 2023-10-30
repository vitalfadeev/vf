module vf.platform.windows.event;

version(WINDOWS):
import core.sys.windows.windows;


struct Event
{
    union {
        MSG         msg;
        PaintEvent  paint;
    }

    auto type()
    {
        return msg.message;
    }
}

alias EVENT_TYPE = typeof(MSG.message);

struct PaintEvent
{
    //
}
