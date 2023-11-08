module vf.base.sensors;

import vf.base.interfaces : ISensAble;
import vf.base.types      : SENSOR;


struct Sensors(Event,EVENT_TYPE)
{
    SENSOR!(Event,EVENT_TYPE)[] _sensors;
    alias _sensors this;

    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach( sensor; _sensors )
            sensor( event, event_type );
    }
}
