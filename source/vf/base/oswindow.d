module vf.base.oswindow;

import vf.base.window         : BaseWindow;
import vf.base.window_manager : BaseWindowManager;

class OSWindow(HWND,Event,EVENT_TYPE) : BaseWindow!(Event,EVENT_TYPE)
{
    HWND hwnd;

    alias TBaseWindow = BaseWindow!(Event,EVENT_TYPE);

    this()
    {
        BaseWindowManager!(TBaseWindow,HWND,Event,EVENT_TYPE)
            .register( this, this.hwnd );
    }
}
