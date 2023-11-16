module vf.window;

version(XCB)
public import vf.platforms.xcb.window : Window;

version(WINDOWS)
public import vf.platforms.window.window : Window;
