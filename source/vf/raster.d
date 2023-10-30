module vf.raster;

version (SDL)
public import vf.platform.sdl.raster;
else
version (WINDOWS)
public import vf.platform.windows.raster;
else
version (XCB)
public import vf.platform.xcb.raster;
else
static assert( 0, "Unsupported platform" );
