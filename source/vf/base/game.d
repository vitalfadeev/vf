module vf.base.game;

import vf.base.sensors : Sensors;


class BaseGame(Queue,Event,EVENT_TYPE)
{
    Sensors!(Event,EVENT_TYPE) sensors;
    Queue   queue;
    int     result;

    void go()
    {
        foreach( ref event; queue )
            sensors.sense( event, event.type );
    }

    void quit( int quit_code=0 )
    {   
        //
    }
}
