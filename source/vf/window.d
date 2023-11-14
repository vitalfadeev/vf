module vf.window;

import vf.base.window_manager : ManagedWindow;

version(XCB)
{
    import vf.platforms.xcb.window;
    alias Window = ManagedWindow!(vf.platforms.xcb.window.Window,typeof(vf.platforms.xcb.window.Window.hwnd));
}
else
version(WINDOWS)
{
    import vf.platforms.windows.window;
    alias Window = ManagedWindow!(vf.platforms.windows.window.Window,typeof(vf.platforms.xcb.window.Window.hwnd));
}
