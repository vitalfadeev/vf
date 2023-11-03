module vf.world;

version(XCB)
public import vf.platforms.xcb.world;
else
version(WINDOWS)
public import vf.platforms.windows.world;
