module vf.base.sensable;


class Sensable(TEvent,TEventType)
{
    alias THIS      = typeof(this);
    alias Event     = TEvent;
    alias EventType = TEventType;

    void sense( Event* event, EventType event_type )
    {
        //
    }
}
