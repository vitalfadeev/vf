module vf.base.oswindow;

import vf.base.window         : BaseWindow;
import vf.base.window_manager : BaseWindowManager;

class BaseOSWindow(HWND,Event,EventType) : BaseWindow!(Event,EventType)
{
    alias BaseWindow = .BaseWindow!(Event,EventType);

    HWND hwnd;


    this()
    {
        BaseWindowManager!(BaseWindow,HWND,Event,EventType)
            .register( this, this.hwnd );
    }
}
