module vf.sensors;

version(XCB)
public import vf.platforms.xcb.sensors;
else
version(WINDOWS)
public import vf.platforms.windows.sensors;
