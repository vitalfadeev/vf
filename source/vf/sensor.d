module vf.sensor;

version (SDL)
public import vf.platform.sdl.sensor;
else
version (WINDOWS)
public import vf.platform.windows.sensor;
else
version (XCB)
public import vf.platform.xcb.sensor;
else
static assert( 0, "Unsupported platform" );
