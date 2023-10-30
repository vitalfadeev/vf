module vf.ui.window;

version (SDL)
public import vf.platform.sdl.ui.window;
else
version (WINDOWS)
public import vf.platform.windows.ui.window;
else
version (XCB)
public import vf.platform.xcb.ui.window;
else
static assert( 0, "Unsupported platform" );
