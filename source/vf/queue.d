module vf.queue;

version(XCB)
public import vf.platforms.xcb.queue;
else
version(WINDOWS)
public import vf.platforms.windows.queue;
