module vf.base.oswindow;

import vf.base.window;


class OSWindow(HWND,Event,EVENT_TYPE) : vf.base.window.Window!(Event,EVENT_TYPE)
{
    HWND hwnd;

    this(ARGS...)( ARGS args )
    {
        super( args );
    }
}
