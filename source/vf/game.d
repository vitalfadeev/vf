module vf.game;

version (SDL)
public import vf.platform.sdl.game;
else
version (WINDOWS)
public import vf.platform.windows.game;
else
version (XCB)
public import vf.platform.xcb.game;
else
static assert( 0, "Unsupported platform" );

