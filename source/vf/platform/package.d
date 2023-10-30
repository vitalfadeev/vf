module vf.platform;

version (SDL)
public import vf.platform.sdl.platform;
else
version (WINDOWS)
public import vf.platform.windows.platform;
else
version (XCB)
public import vf.platform.xcb.platform;
else
static assert( 0, "Unsupported platform" );


Platform platform = void;

static
this()
{
    platform.do_init();
}
