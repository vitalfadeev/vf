module vf.platform;

version(XCB)
public import vf.platforms.xcb.platform;
else
version(WINDOWS)
public import vf.platforms.windows.platform;
