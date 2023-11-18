module vf.base.sensable;


class SensAble(TEvent,TEventType)
{
    alias THIS      = typeof(this);
    alias Sensable  = typeof(this);
    alias Event     = TEvent;
    alias EventType = TEventType;

    void sense( Event* event, EventType event_type )
    {
        //
    }
}
