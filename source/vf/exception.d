module vf.exception;

version(XCB)
public import vf.platforms.xcb.exception;
else
version(WINDOWS)
public import vf.platforms.windows.exception;
