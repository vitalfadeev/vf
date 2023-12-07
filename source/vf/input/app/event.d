module vf.input.app.la;

import vf.element      : Element;
import vf.base.timeval : Timeval;


enum AppLaType : ushort
{
    EV_APP_                = EV_APP,
    EV_APP_ELEMENT_UPDATED = EV_APP +  8,  
    EV_APP_TIMER           = EV_APP +  9,
    EV_APP_QUIT            = EV_APP + 10,
}                          // 0x00000000_00000000
                           //     source     type

enum EV_APP_ELEMENT_UPDATED = AppLaType.EV_APP_ELEMENT_UPDATED;
enum EV_APP_TIMER           = AppLaType.EV_APP_TIMER;
enum EV_APP_QUIT            = AppLaType.EV_APP_QUIT;

struct AppLa
{
    Timeval   timeval;
    LaType la_type;
    union {
        ElementUpdatedLa element_updated;
    }

    this( ElementUpdatedLa a )
    {
        timeval         = Timeval.now;
        la_type      = EV_APP_ELEMENT_UPDATED;
        element_updated = a;
    }

    struct LaType
    {
        ushort type;  // AppLaType
        ushort code;
        uint   value;
    }
}


struct ElementUpdatedLa
{
    Element element;
}
