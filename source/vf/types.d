module vf.types;

version(XCB)
public import vf.platforms.xcb.types;
else
version(WINDOWS)
public import vf.platforms.windows.types;
