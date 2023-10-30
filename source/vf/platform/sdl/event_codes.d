module vf.platform.sdl.event_codes;

version(SDL):
static import winapi=core.sys.windows.windows;

enum WM_PAINT = winapi.WM_PAINT;
enum WM_LBUTTONDOWN = winapi.WM_LBUTTONDOWN;
enum WM_DESTROY = winapi.WM_DESTROY;
