module vf.event;

version(XCB)
public import vf.platforms.xcb.event;
else
version(WINDOWS)
public import vf.platforms.windows.event;
