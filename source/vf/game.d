module vf.game;

public import vf.types;

version (SDL)
public import vf.platform.sdl.game;
else
version (WINDOWS_NATIVE)
public import vf.platform.windows.game;
else
static assert( 0, "Unsupported platform" );
