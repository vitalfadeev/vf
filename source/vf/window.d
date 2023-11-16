module vf.window;

version(XCB)
public import vf.platforms.xcb.window : Window=XCBWindow;

version(WINDOWS)
public import vf.platforms.window.window : Window;
