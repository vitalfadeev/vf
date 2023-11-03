module vf.base.game;

import vf.base.interfaces : ISensAble;


class Game(Queue,Event,EVENT_TYPE)
{
    Sensors!(Event,EVENT_TYPE) sensors;
    Queue   queue;
    int     result;

    void go()
    {
        foreach( event; queue )
            sensors.sense( &event, event.type );
    }

    void quit( int quit_code=0 )
    {   
        //
    }
}


struct Sensors(Event,EVENT_TYPE)
{
    ISensAble!(Event,EVENT_TYPE)[] _sensors;
    alias _sensors this;

    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach( sensor; _sensors )
            sensor.sense( event, event_type );
    }
}
