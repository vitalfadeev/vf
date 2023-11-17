module vf.base.oswindow;

import vf.base.window         : BaseWindow;
import vf.base.window_manager : BaseWindowManager;

class BaseOSWindow(HWND,Event,EventType) : BaseWindow!(Event,EventType)
{
    HWND hwnd;

    alias TBaseWindow = BaseWindow!(Event,EventType);

    this()
    {
        BaseWindowManager!(TBaseWindow,HWND,Event,EventType)
            .register( this, this.hwnd );
    }
}
