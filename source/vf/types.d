module vf.types;

version (SDL)
public import vf.platform.sdl.types;
else
version (WINDOWS)
public import vf.platform.windows.types;
else
version (XCB)
public import vf.platform.xcb.types;
else
static assert( 0, "Unsupported platform" );
