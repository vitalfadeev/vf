module vf.element;

version(WINDOWS)
public import vf.platforms.windows.element;
else
version(XCB)
public import vf.platforms.xcb.element;
