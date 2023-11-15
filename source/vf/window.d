module vf.window;

version(XCB)
import vf.platforms.xcb.window_manager : ManagedWindow;

version(WINDOWS)
import vf.platforms.window.window_manager : ManagedWindow;

alias Window = ManagedWindow;
