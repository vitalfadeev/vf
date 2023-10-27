module vf.raster;

version (SDL)
public import vf.platform.sdl.raster;
else
version (WINDOWS_NATIVE)
public import vf.platform.windows.raster;
else
version (LINUX_X11)
public import vf.platform.linux.raster;
else
static assert( 0, "Unsupported platform" );
