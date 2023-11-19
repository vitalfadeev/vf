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
import vf.base.fixed           : Fixed;
import vf.platforms.xcb.event  : Event, EventType;
import vf.platforms.xcb.wx     : WX;


class Button : Element
{
    mixin auto_methods!(typeof(this));  // sense()
    //mixin auto_cap!(typeof(this));

    override
    void draw()
    {
        clear();
        point_at( -10, -10 ); point_at( 0, -10 ); point_at( +10, -10 );
        point_at( -10,   0 ); point_at( 0,   0 ); point_at( +10,   0 );
        point_at( -10, +10 ); point_at( 0, +10 ); point_at( +10, +10 );
    }

    void to_pressed()
    {
        //
    }

    void to_disabled()
    {
        //
    }

    ////
    //class Pressed
    //{
    //    mixin auto_methods!(typeof(this));  // sense()

    //    void draw()
    //    {
    //        drawable.point( 0, 0 );  // drawable
    //    }

    //    void to_()
    //    {
    //        //
    //    }

    //    void to_disabled()
    //    {
    //        //
    //    }
    //}

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
} 


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

