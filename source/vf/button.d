module vf.button;

import vf.interfaces;
import vf.auto_methods;
import vf : Event, EVENT_TYPE;


class World : ISensAble, IEnterAble
{
    mixin auto_methods!(typeof(this));
}

class Button : ISensAble, IEnterAble, IDrawAble
{
    mixin auto_methods!(typeof(this));

    void draw()
    {
        point( 0, 0 );  // drawable
    }

    void to_pressed()
    {
        //
    }

    void to_disabled()
    {
        //
    }

    //
    class Pressed : ISensAble, IEnterAble, IDrawAble
    {
        mixin auto_methods!(typeof(this));

        void draw()
        {
            point( 0, 0 );  // drawable
        }

        void to_()
        {
            //
        }

        void to_disabled()
        {
            //
        }
    }

    class Disabled : ISensAble, IEnterAble, IDrawAble
    {
        mixin auto_methods!(typeof(this));

        void draw()
        {
            point( 0, 0 );  // drawable
        }

        void to_pressed()
        {
            //
        }

        void to_()
        {
            //
        }
    }
} 


void init_world()
{
    import vf : DrawEvent;

    auto world = new World();
    world.enter.put( new Button() );

    Event event;
    event.draw = DrawEvent();
    world.sense( &event, event.type );
}

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

