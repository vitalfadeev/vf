module vf.queue;

version (SDL)
public import vf.platform.sdl.queue;
else
version (WINDOWS)
public import vf.platform.windows.queue;
else
version (XCB)
public import vf.platform.xcb.queue;
else
static assert( 0, "Unsupported platform" );
