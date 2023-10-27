module vf.queue;

version (SDL)
public import vf.platform.sdl.queue;
else
version (WINDOWS_NATIVE)
public import vf.platform.windows.queue;
else
version (LINUX_X11)
public import vf.platform.linux.queue;
else
static assert( 0, "Unsupported platform" );
