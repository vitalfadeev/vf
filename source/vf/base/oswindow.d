module vf.base.oswindow;

import vf.base.window : BaseWindow;

class BaseOSWindow(HWND,Event,EventType) : BaseWindow!(Event,EventType)
{
    alias THIS         = typeof(this);
    alias BaseOSWindow = typeof(this);

    HWND hwnd;
}
