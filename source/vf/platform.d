module vf.platform;

version(XCB)
import vf.platforms.xcb.platform : Platform;


Platform platform = void;

static
this()
{
    platform.do_init();
}
