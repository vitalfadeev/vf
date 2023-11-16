module vf.base.oswindow;

import vf.base.window;
import vf.base.window_manager : WindowManager;

class OSWindow(HWND,Event,EVENT_TYPE) : vf.base.window.Window!(Event,EVENT_TYPE)
{
    HWND hwnd;

    alias BaseWindow = vf.base.window.Window!(Event,EVENT_TYPE);

    this()
    {
        WindowManager!(BaseWindow,HWND,Event,EVENT_TYPE)
            .register( this, this.hwnd );
    }
}
