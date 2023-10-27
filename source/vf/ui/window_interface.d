module vf.ui.window_interface;

import vf.types;


interface IWindow 
{
    ERESULT event( EVENT_TYPE event_type, Event* event );
}
