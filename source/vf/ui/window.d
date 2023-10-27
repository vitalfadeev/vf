module vf.ui.window;

version (SDL)
public import vf.platform.sdl.ui.window;
else
version (WINDOWS_NATIVE)
public import vf.platform.windows.ui.window;
else
version (LINUX_X11)
public import vf.platform.linux.ui.window;
else
static assert( 0, "Unsupported platform" );
