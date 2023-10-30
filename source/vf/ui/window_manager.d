module vf.ui.window_manager;

version (SDL)
public import vf.platform.sdl.ui.window_manager;
else
version (WINDOWS)
public import vf.platform.windows.ui.window_manager;
else
version (XCB)
public import vf.platform.xcb.ui.window_manager;
else
static assert( 0, "Unsupported platform" );
