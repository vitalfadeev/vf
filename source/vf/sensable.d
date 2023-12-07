module vf.sensable;

import vf.base.sensable;


version(Windows)
{
    import vf.platforms.windows.la : La, LaType;
    alias Sensable = vf.base.sensable.SensAble!(La,LaType);
}

version(XCB)
{
    import vf.platforms.xcb.la : La, LaType;
    alias Sensable = vf.base.sensable.SensAble!(La,LaType);
}
