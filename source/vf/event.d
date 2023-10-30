module vf.event;

version (SDL)
public import vf.platform.sdl.event;
else
version (WINDOWS)
public import vf.platform.windows.event;
else
version (XCB)
public import vf.platform.xcb.event;
else
version (XLIB)
public import vf.platform.xlib.event;
else
static assert( 0, "Unsupported platform" );
