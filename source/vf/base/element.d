module vf.base.element;

import vf.base.enterable : EnterAble;


//import std.range          : InputRange;
//import std.range          : front, empty, popFront, moveFront;
//import vf.base.interfaces : IEnterAble;
//import vf.base.interfaces : ISensAble;
//import vf.base.drawable   : DrawAble;


alias 
Element (La,LaType,WX) = EnterAble!(La,LaType,WX);


//class Element(La,LaType) : ISensAble!(La,LaType), IEnterAble
//{
//    // ISensAble
//    void sense( La* la, LaType la_type )
//    //      this       la             la_type         
//    //      RDI        RSI               RDX
//    {
//        //
//    }

//    // IEnterAble
//    EnterElement!(La,LaType) enter;

//    // IDrawAble
//    DrawAble drawable;

//    // ILayoutAble
//    LayoutAble layoutable;
//}


//struct EnterElement(La,LaType)
//{
//    alias E = Element!(La,LaType);

//    E[] _range;


//    E    front()     { return _range.front; }
//    bool empty()     { return _range.empty; }
//    void popFront()  { _range.popFront(); }
//    E    moveFront() { return _range.moveFront; }
//    void put( E o )  { _range ~= o; }

//    int opApply( scope int delegate(E) dg )  
//    {
//        int result = 0;

//        foreach( e; _range )
//            if ( ( result = dg( e ) ) != 0 )
//                break;

//        return result;
//    }

//    int opApply( scope int delegate(size_t, E) dg )  
//    {
//        int result = 0;

//        foreach( i, e; _range )
//            if ( ( result = dg( i, e ) ) != 0 )
//                break;

//        return result;
//    }

//    void sense( La* la, LaType la_type )
//    {
//        foreach( ref e; _range )
//            e.sense( la, la_type );
//    }
//}
