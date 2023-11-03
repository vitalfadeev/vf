module vf.interfaces;

import std.range : InputRange;
//import vf.event  : Event, EVENT_TYPE;


//
interface IEnterAble
{
    @property IEnterRange enter();
}

interface IEnterRange : InputRange!ISensAble
{
    void put( ISensAble o );
    void sense(Event,EVENT_TYPE)( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
    ISensAble[] find( ISensAble sensor );
}


//
interface IDrawAble
{
    void point( int x, int y );
}

interface IHitAble
{
    void hit( int x, int y );
}

//
interface ISensAble
{
    void sense(Event,EVENT_TYPE)( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

//
interface IWindow
{
    void sense(Event,EVENT_TYPE)( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

interface IWindowManager(T,W)
{
    T vf_window( W os_window );
    void register( W os_window, T vf_window );
    void unregister( W os_window );
}
