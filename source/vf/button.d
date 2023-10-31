module vf.button;

import vf.interfaces;
import vf.auto_methods;
import vf : Event, EVENT_TYPE;

enum DRAW = 1;

class Button : ISense, IOuter
{
    mixin auto_methods!(typeof(this));

    void on_DRAW( Event* event, EVENT_TYPE event_type )
    {
        auto d = event.draw.idraw;
        d.point( 0, 0 );
    }
}
