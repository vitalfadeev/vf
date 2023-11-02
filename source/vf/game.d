module vf.game;

version(XCB)
public import vf.platforms.xcb.game;
else
version(WINDOWS)
public import vf.platforms.windows.game;
