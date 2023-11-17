module vf.base.sensors;

import vf.base.interfaces : ISensAble;
import vf.base.types      : SENSOR;


struct Sensors(Event,EventType)
{
    SENSOR!(Event,EventType)[] _sensors;
    alias _sensors this;

    void sense( Event* event, EventType event_type )
    {
        foreach( sensor; _sensors )
            sensor( event, event_type );
    }
}
