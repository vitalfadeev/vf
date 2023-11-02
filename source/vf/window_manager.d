module vf.window_manager;

version(XCB)
public import vf.platforms.xcb.window_manager;
else
version(WINDOWS)
public import vf.platforms.windows.window_manager;


//
WindowManager window_manager;

static
this()
{
    window_manager = new WindowManager();
}
