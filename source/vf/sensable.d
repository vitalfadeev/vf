module vf.sensable;

import vf.base.sensable;


version(Windows)
{
    import vf.platforms.windows.event : Event, EVENT_TYPE;
    alias Sensable = vf.base.sensable.Sensable!(Event,EVENT_TYPE);
}

version(XCB)
{
    import vf.platforms.xcb.event : Event, EVENT_TYPE;
    alias Sensable = vf.base.sensable.Sensable!(Event,EVENT_TYPE);
}
