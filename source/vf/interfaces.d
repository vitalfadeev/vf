module vf.interfaces;

version(WINDOWS)
public import vf.platforms.windows.interfaces;
else
version(XCB)
public import vf.platforms.xcb.interfaces;
