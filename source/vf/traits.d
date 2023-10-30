module vf.traits;


// isDerivedFromInterface!(O,ISenseAble) == true
template isDerivedFromInterface(T,A)
{ 
    import std.traits;
    import std.meta;

    template isEqual(A) { enum isEqual = is( T == A ); }

    static if ( anySatisfy!( isEqual!A, InterfacesTuple!T ) )
        enum isDerivedFromInterface = true;
    else
        enum isDerivedFromInterface = false;
}

// isSameInstaneSize!(Chip_Init,Chip_Hovered) == true
template isSameInstaneSize(CLS,T)
{
    static if ( __traits( classInstanceSize, CLS ) != __traits( classInstanceSize, T ) )
        enum isSameInstaneSize = true;
    else
        enum isSameInstaneSize = false;
}

// TXYXY = Detect8bitAlignedType!(TX,TX)
// Detect8bitAlignedType!(uint,uint) == ulong
template Detect8bitAlignedType(TX,TY)
{
    static if ( TX.sizeof + TY.sizeof <= 8 )
        alias Detect8bitAlignedType = ubyte;
    else
    static if ( TX.sizeof + TY.sizeof <= 16 )
        alias Detect8bitAlignedType = ushort;
    else
    static if ( TX.sizeof + TY.sizeof <= 32 )
        alias Detect8bitAlignedType = uint;
    else
    static if ( TX.sizeof + TY.sizeof <= 64 )
        alias Detect8bitAlignedType = ulong;
    else
    static if ( TX.sizeof + TY.sizeof <= 128 )
        alias Detect8bitAlignedType = ucent;
    else
        static assert( 0, "Expected size TX+TY <= 128" );
}


// hasMember!(T, "sense")
template hasMethod(T,string M)
{
    import std.traits;

    static if ( hasMember!(T,M)/* && isCallable!(__traits(getMember,T,M))*/ )
        enum hasMethod = true;
    else
        enum hasMethod = false;
}

// Raster
//   .line(x,y)
//   .Cast!Raster
//   .to_window( hdc, hwmd )
auto Cast(TO,FROM)(FROM from)
{
    return cast(TO)from;
}


// get all handlers of T
// example:
//   alias handlers = Handlers!HandlerStruct;
// example of valid T:
//  struct HandlerStruct
//  {
//      static
//      void on_T1( REG edi, Event* event )
//      {
//          //
//      }
//  }
template Handlers(T)
{
    import std.meta : AliasSeq, Filter;

    static if (
        is(T == struct) || 
        is(T == union) ||
        is(T == class) || 
        is(T == interface)
    )
    {
        alias all_members = __traits( allMembers, T );
        alias Handlers = AliasSeq!();

        static foreach ( name; all_members )
            static if ( isHandler!(T,name) )
                Handlers = AliasSeq!( Handlers, __traits( getMember, T, name ) );
    }
    else
        alias Handlers = AliasSeq!T;
}

// check T for:
//   static
//   on_...
// example of valid T:
//   static
//   void on_T1( REG edi, Event* event )
//   {
//       //
//   }
template isHandler(T, string name)
{
    import std.algorithm.searching : startsWith;
    import std.traits : isCallable;

    alias member = __traits( getMember, T, name );

    static if (
        isCallable!member &&
        name.startsWith("on_")
    )
        enum isHandler = true;
    else
        enum isHandler = false;
}


// Handled event types
template HandledEvents(T)
{
    import std.meta : AliasSeq, Filter;

    static if (
        is(T == struct) || 
        is(T == union) ||
        is(T == class) || 
        is(T == interface)
    )
    {
        alias all_members = __traits( allMembers, T );
        alias HandledEvents = AliasSeq!();

        static foreach ( name; all_members )
            static if ( isHandler!(T,name) )
                HandledEvents = AliasSeq!( HandledEvents, name[ 3..$ ] );  // strip "on_"
    }
    else
        alias HandledEvents = AliasSeq!T;
}


// Handled event types returns enum values
template HandledEventsE(T,alias E)
{
    import std.meta : AliasSeq, Filter;

    static if (
        is(T == struct) || 
        is(T == union) ||
        is(T == class) || 
        is(T == interface)
    )
    {
        alias all_members = __traits( allMembers, T );
        alias HandledEventsE = AliasSeq!();

        static foreach ( name; all_members )
            static if ( isHandler!(T,name) )
                HandledEventsE = AliasSeq!( HandledEventsE, __traits(getMember, E, name[ 3..$ ]) );  // Event.ENUM_MEMBER
    }
    else
        alias HandledEventsE = AliasSeq!T;
}


// hasHandler!(Handler,__traits(getMember,Handler,on_T1))
template hasHandler(T, alias M)
{
    enum proc_name = "on_" ~ __traits( identifier, M );
    enum hasHandler = 
        __traits( hasMember, T, proc_name ) &&
        isHandler!(T, proc_name);
}


template HandlerName(alias T)
{
    enum HandlerName = __traits( identifier, T );
}


string Platf( string name )
{
    import std.string : toLower;
    import std.format : format;
    string[] versions = ["SDL","WINDOWS","XCB"];

    string s;

    foreach( v; versions )
        s ~=  
            format!
                "version (%s) public import vf.platform.%s.%s;"
                ( v, v.toLower, name );

    s ~= "else static assert( 0, \"Unsupported platform\" );";

    return s;
}
