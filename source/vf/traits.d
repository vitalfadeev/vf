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
//      void on_T1( REG edi, La* la )
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
//   void on_T1( REG edi, La* la )
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


// Handled la types
template HandledLas(T)
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
        alias HandledLas = AliasSeq!();

        static foreach ( name; all_members )
            static if ( isHandler!(T,name) )
                HandledLas = AliasSeq!( HandledLas, name[ 3..$ ] );  // strip "on_"
    }
    else
        alias HandledLas = AliasSeq!T;
}


// Handled la types returns enum values
template HandledLasE(T,alias E)
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
        alias HandledLasE = AliasSeq!();

        static foreach ( name; all_members )
            static if ( isHandler!(T,name) )
                HandledLasE = AliasSeq!( HandledLasE, __traits(getMember, E, name[ 3..$ ]) );  // La.ENUM_MEMBER
    }
    else
        alias HandledLasE = AliasSeq!T;
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
                "version (%s) public import vf.platforms.%s.%s;"
                ( v, v.toLower, name );

    s ~= "else static assert( 0, \"Unsupported platform\" );";

    return s;
}


template hasInterface(T,I)
{
     import std.traits : InterfacesTuple;
     import std.meta   : staticIndexOf, AliasSeq;

     enum hasInterface = 
        ( staticIndexOf!( AliasSeq!( I, InterfacesTuple!T ) ) != -1 );
}

template interfaces_of(T)
{
     import std.traits : InterfacesTuple;

     alias interfaces_of = InterfacesTuple!T;
}

template all_interfaces(alias M)
    if ( is( M == module ) )
{
    import std.meta : AliasSeq, Filter;
    import std.traits : InterfacesTuple;

    alias all_members = __traits( allMembers, M );
    alias all_interfaces = AliasSeq!();

    static foreach ( name; all_members )
        static if ( is_interface!(M,name) )
            all_interfaces = AliasSeq!( all_interfaces, __traits( getMember, M, name ) );
}
template is_interface(alias T,string name)
{
    import std.algorithm.searching : startsWith;
    import std.traits : isCallable;

    alias member = __traits( getMember, T, name );

    static if ( is( member == interface ))
        enum is_interface = true;
    else
        enum is_interface = false;
}
template interface_name(alias T)
{
    enum interface_name = __traits( identifier, T );
}


// A a;
// Switch!(A, A.ONE,A.TWO, xx)( A._ );
// Switch!(A, A.ONE,A.TWO, xx)( A.ONE );
// Switch!(A, A.ONE,A.TWO, xx)( A.TWO );
//   xx()
void
Switch (T,ARGS...) (T a) {
    mixin ( "switch (a) {\n" ~ _SwitchCases!(0,T,ARGS) ~ "  default:\n}" );
}

template
_SwitchCases (size_t i,T,ARGS...) { 
    import std.format : format;

    static if (ARGS.length == 0)
        enum _SwitchCases = "";
    else
    {
        static if (is(typeof(ARGS[0]) == T))
            enum _SwitchCases = format!"  case %s.%s:\n"(T.stringof,ARGS[0].stringof) ~
                _SwitchCases !(i+1,T,ARGS[1..$]);
        else
            enum _SwitchCases = format!"    ARGS[%d](a); break;\n" (i) ~ 
                _SwitchCases !(i+1,T,ARGS[1..$]);
    }
}
