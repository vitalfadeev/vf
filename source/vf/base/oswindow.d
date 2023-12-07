module vf.base.oswindow;

import vf.base.window : BaseWindow;

class BaseOSWindow(HWND,La,LaType) : BaseWindow!(La,LaType)
{
    alias THIS         = typeof(this);
    alias BaseOSWindow = typeof(this);

    HWND hwnd;
}
