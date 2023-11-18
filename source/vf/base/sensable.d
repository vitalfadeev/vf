module vf.base.sensable;


class Sensable(TEvent,TEventType)
{
    alias Event     = TEvent;
    alias EventType = TEventType;

    void sense( Event* event, EventType event_type )
    {
        //
    }
}
