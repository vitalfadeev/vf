module vf.window;

version(XCB)
public import vf.platforms.xcb.window;
else
version(WINDOWS)
public import vf.platforms.windows.window;
