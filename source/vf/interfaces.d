module vf.interfaces;

import vf : Event, EVENT_TYPE;
public import vf : ISense;


//
interface IOuter
{
    @property IInner inner();
}

interface IInner
{
    @property IOuter outer();
}

//
interface IDraw
{
    void point( int x, int y );
}
