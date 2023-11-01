module vf.interfaces;

import std.range : InputRange;
version(XCB)
import vf.platforms.xcb.event : Event, EVENT_TYPE;


//
interface IEnterAble
{
    @property IEnterRange enter();
}

interface IEnterRange
{
    void put( ISensAble o );
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

class EnterRange : IEnterRange
{
    ISensAble[] _range;

    void put( ISensAble o )
    {
        _range ~= o;
    }

    void sense( Event* event, EVENT_TYPE event_type )
    {
        foreach( o; _range )
            o.sense( event, event_type );
    }
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
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

//
interface IWindow
{
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

interface IWindowManager(T,W)
{
    T vf_window( W os_window );
    void register( W os_window, T vf_window );
    void unregister( W os_window );
}
