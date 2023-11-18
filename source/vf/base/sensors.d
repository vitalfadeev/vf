module vf.base.sensors;

import vf.base.types : Sensor;


struct Sensors(Event,EventType)
{
    Sensor!(Event,EventType)[] _sensors;
    alias _sensors this;

    void sense( Event* event, EventType event_type )
    {
        foreach( sensor; _sensors )
            sensor( event, event_type );
    }
}
