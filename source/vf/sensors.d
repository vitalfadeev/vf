module vf.sensors;

version (SDL)
public import vf.platform.sdl.sensors;
else
version (WINDOWS)
public import vf.platform.windows.sensors;
else
version (XCB)
public import vf.platform.xcb.sensors;
else
static assert( 0, "Unsupported platform" );
