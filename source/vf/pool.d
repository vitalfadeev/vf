module vf.pool;

version (SDL)
public import vf.platform.sdl.pool;
else
version (WINDOWS_NATIVE)
public import vf.platform.windows.pool;
else
static assert( 0, "Unsupported platform" );
