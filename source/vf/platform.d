module vf.platform;

version(XCB)
import vf.platforms.xcb.platform : Platform;
else
version(WINDOWS)
public import vf.platforms.windows.platform : Platform;

//
Platform platform = void;

static
this()
{
    platform.do_init();
}
