module vf.platform;

version (SDL)
public import vf.platform.sdl;
else
version (WINDOWS)
public import vf.platform.windows;
else
version (XCB)
public import vf.platform.xcb;
else
version (XLIB)
public import vf.platform.xlib;
else
static assert( 0, "Unsupported platform" );


Platform platform = void;

static
this()
{
    platform.do_init();
}
