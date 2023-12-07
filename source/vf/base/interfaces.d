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
//    void sense( La* la, LaType la_type );
//    //      this       la             la_type         
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
interface ISensAble(La,LaType)
{
    void sense( La* la, LaType la_type );
    //      this       la             la_type         
    //      RDI        RSI               RDX
}

//
interface IWindow(La,LaType)
{
    void sense( La* la, LaType la_type );
    //      this       la             la_type         
    //      RDI        RSI               RDX
}

interface IWindowManager(V,O)
{
    V vf_window( O os_window );
    void register( O os_window, V vf_window );
    void unregister( O os_window );
}
