module vf.button;

import vf.auto_methods;
import vf.element : Element;


//class View
//{
//    World world;
//    uint  scale;
//    uint  xy;
//    uint  wh;

//    void render( World world )
//    {
//        import vf.base.drawable : DrawAble;
//        DrawAble drawable;

//        foreach( e; world.enter )
//            drawable.ops ~= e.drawable.ops;

//        //
//    }

//    //void to_pixmap( IPixmap pixmap )
//    void to_window( IWindow window )
//    {
//        // foreach( el; world )
//        //     draw_tree ~= el;
//        //
//        // draw_tree.render();
//    }
//}

//class World : ISensAble, IEnterAble
//{
//    mixin auto_methods!(typeof(this));
//    mixin auto_cap!(typeof(this));
//}

//enum CAP {
//    _          = 0b0000_0000,
//    ISENSEABLE = 0b0000_0001,
//    IENTERABLE = 0b0000_0010,
//    IDRAWABLE  = 0b0000_0100,
//    IHITABLE   = 0b0000_1000,
//}
//mixin( _auto_cap_enum!(vf.platforms.windows.interfaces) );

//string _auto_cap_enum(alias M)()
//{
//    import std.format : format;
//    import std.string : toUpper;
//    import vf.traits  : all_interfaces, interface_name;

//    string s;

//    s ~= "enum CAP {\n";
//    s ~= "                                 _ = 0,\n";

//    static foreach( i, I; all_interfaces!M )
//        s ~= format!"  %32s = 0b%032b,\n"( (interface_name!I).toUpper, (1 << i) );

//    s ~= "}";

//    return s;
//}


import xcb.xcb                 : XCB_EVENT_MASK_BUTTON_PRESS;
import xcb.xcb                 : XCB_EVENT_MASK_BUTTON_RELEASE;
import vf.base.fixed           : Fixed;
import vf.platforms.xcb.event  : Event, EventType;
import vf.platforms.xcb.wx     : WX;
import vf.platforms.xcb.color  : Colors;


class Button : Element
{
    alias THIS   = typeof(this);
    alias Button = typeof(this);

    mixin auto_methods!(typeof(this));  // sense()
    //mixin auto_cap!(typeof(this));
    mixin StateAble!(typeof(this));

    override
    void sense( Event* event, EventType event_type )
    {
        super.sense( event, event_type );

        // try go to new state
        //static if( StateAble && hasMethod!"to" )
        try_to_( this, event, event_type );
    }


    override
    void draw()
    {
        clear();
        color( Colors.primary );
        point_at( -10, -10 ); point_at( 0, -10 ); point_at( +10, -10 );
        point_at( -10,   0 ); point_at( 0,   0 ); point_at( +10,   0 );
        point_at( -10, +10 ); point_at( 0, +10 ); point_at( +10, +10 );
    }

    void to_pressed( Event* event, EventType event_type )
    {
        //                 M32
        if ( event_type == EV_KEY_KEY_A ) if ( hit_test( event.button_press_wx ) ) { to!Pressed(); redraw(); }

        //                 M64
        if ( event_type == EV_KEY_KEY_A_DOWN ) if ( hit_test( event.button_press_wx ) ) { to!Pressed(); redraw(); }

        // key A down  - include/uapi/linux/input-event-codes.h
        switch ( event_type.code ) {
            case EV_KEY: switch ( event_type.detail ) {
                case KEY_A: if ( value == 1 ) if ( hit_test( event.button_press_wx ) ) to!Pressed(); redraw(); break;
                default:}
            default:
        }

        // key A down  - Winuser.h                   M16     M16
        switch ( event_type.code ) { // WM_KEYDOWN = 0x0100, detail = wParam, VK_A = 0x41
            case WM_KEYDOWN: switch ( event_type.detail ) {
                case VK_A: if ( hit_test( event.button_press_wx ) ) to!Pressed(); redraw(); break;
                default:}
            default:
        }

        // key A down  - X11/keysymdef.h
        switch ( event_type.response_type ) { // XK_A = 0x0041
            case XCB_EVENT_MASK_KEY_PRESS: switch ( event_type.detail ) {
                case XK_A: if ( hit_test( event.button_press_wx ) ) to!Pressed(); redraw(); break;
                default:}
            default:
        }

        // key A down  - SDL/include/SDL_scancode.h
        switch ( event_type.response_type ) { // SDL_SCANCODE_A = 0x0004
            case SDL_KEYDOWN: switch ( event_type.detail ) { // keysym.scancode
                case SDL_SCANCODE_A: if ( hit_test( event.button_press_wx ) ) to!Pressed(); redraw(); break;
                default:}
            default:
        }

        //
        switch ( event_type )
        {
            case XCB_EVENT_MASK_BUTTON_PRESS: if ( hit_test( event.button_press_wx ) ) to!Pressed(); redraw(); break;
            default:
        }
    }

    void to_disabled( Event* event, EventType event_type )
    {
        //
    }


    // States
    class Pressed : Button
    {
        mixin auto_methods!(typeof(this));  // sense()

        override
        void draw()
        {
            clear();
            color( Colors.secondary );
            point_at( -10, -10 ); point_at( 0, -10 ); point_at( +10, -10 );
            point_at( -10,   0 ); point_at( 0,   0 ); point_at( +10,   0 );
            point_at( -10, +10 ); point_at( 0, +10 ); point_at( +10, +10 );
        }

        void to_normal( Event* event, EventType event_type )
        {
            switch ( event_type )
            {
                case XCB_EVENT_MASK_BUTTON_RELEASE: to!Button(); break;
                default:
            }
        }
    }
} 

//

    //class Disabled : ISensAble, IEnterAble, IDrawAble
    //{
    //    mixin auto_methods!(typeof(this));

    //    void draw()
    //    {
    //        drawable.point( 0, 0 );  // drawable
    //    }

    //    void to_pressed()
    //    {
    //        //
    //    }

    //    void to_()
    //    {
    //        //
    //    }
    //}


//void init_world()
//{
//    import vf : DrawEvent;

//    auto world = new World();
//    world.enter.put( new Button() );

//    Event event;
//    event.draw = DrawEvent();
//    world.sense( &event, event.type );
//}

// on PAINT
//   rasterize
//
// on PAINT rect
//   find objects in rect
//   foreach
//     get limits
//       get draw
//       get limits
//     rasterize
//


mixin template StateAble( T )
{
    void to(CLS)()
    {
        // o
        //   state -> state'

        // o
        //   __vptr
        //   __monitor
        //   interfaces
        //   fields
        import std.conv;
        import vf.traits : isSameInstaneSize;

        // object.sizeof != object.sizeof
        //   assert
        static 
        if ( !isSameInstaneSize!(CLS,T) )
            static assert( "Class instance size must be equal. " ~ 
                CLS.stringof ~ " and " ~ typeof(this).stringof ~ ". " ~  
                __traits( classInstanceSize, CLS ).to!string ~ " != " ~ __traits( classInstanceSize, typeof(this) ).to!string ~ "."
            );

        //
        this.__vptr = cast(immutable(void*)*)typeid(CLS).vtbl.ptr;
    }
}

// Try
//   to_Init()
//   to_Hover()
//pragma( inline, true )
void try_to_(THIS)( THIS _this, Event* event, EventType event_type )
{
    import std.string;
    import std.traits;

    static foreach( m; __traits( allMembers, THIS ) )
        static if ( isCallable!(__traits( getMember, THIS, m )) )
            static if ( m.startsWith( "to_" ) && m != "to_raster" )
                __traits( getMember, _this, m )( event, event_type ); 
}
