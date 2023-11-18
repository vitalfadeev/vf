module vf.sensable;

import vf.base.sensable;


version(Windows)
{
    import vf.platforms.windows.event : Event, EventType;
    alias Sensable = vf.base.sensable.SensAble!(Event,EventType);
}

version(XCB)
{
    import vf.platforms.xcb.event : Event, EventType;
    alias Sensable = vf.base.sensable.SensAble!(Event,EventType);
}
