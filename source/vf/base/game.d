module vf.base.game;

import vf.base.sensors : Sensors;


class BaseGame(Queue,Event,EventType)
{
    Sensors!(Event,EventType) sensors;
    Queue   queue;
    int     result;

    void go()
    {
        foreach( ref event; queue )
        {
            sensors.sense( &event, event.type );

            if ( event.is_quit )
                break;
        }
    }

    void quit( int quit_code=0 )
    {   
        //
    }
}
