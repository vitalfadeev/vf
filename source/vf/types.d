module vf.types;

version (SDL)
public import vf.platform.sdl.types;
else
version (WINDOWS_NATIVE)
public import vf.platform.windows.types;
else
static assert( 0, "Unsupported platform" );
