module vf.queue;

version (SDL)
public import vf.platform.sdl.queue;
else
version (WINDOWS_NATIVE)
public import vf.platform.windows.queue;
else
static assert( 0, "Unsupported platform" );
