module vf.button;

import vf.interfaces;
import vf.auto_methods;
import vf : Event, EVENT_TYPE;

enum DRAW = 1;

class Button : ISense, IOuter
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
    class Pressed
    {
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

    class Disabled
    {
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


// on PAINT
//   rasterize
//
// on PAINT rect
//   find objects in rect
//   foreach
//     get draw
//     rasterize
