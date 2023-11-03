module vf.base.interfaces;

//import std.range : InputRange;


//
interface IEnterAble
{
    //@property IEnterRange enter();
}

//interface IEnterRange : InputRange!ISensAble
//{
//    void put( ISensAble o );
//    void sense( Event* event, EVENT_TYPE event_type );
//    //      this       event             event_type         
//    //      RDI        RSI               RDX
//    ISensAble[] find( ISensAble sensor );
//}


//
interface IDrawAble
{
    //void point( int x, int y );
}

interface IHitAble
{
    void hit( int x, int y );
}

//
interface ISensAble(Event,EVENT_TYPE)
{
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

//
interface IWindow(Event,EVENT_TYPE)
{
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
}

interface IWindowManager(V,O)
{
    V vf_window( O os_window );
    void register( O os_window, V vf_window );
    void unregister( O os_window );
}
