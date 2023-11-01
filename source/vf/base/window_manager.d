module vf.base.window_manager;

// hwnd -> window
// window -> hwnd
class WindowManager(T,W)
{
    W[] _os_windows;
    T[] _vf_windows;

    T vf_window( W os_window )
    {
        import std.algorithm.searching : countUntil;
        auto i = _os_windows.countUntil( os_window );

        return _vf_windows[i];
    }

    void register( W os_window, T vf_window )
    {
        _os_windows ~= os_window;
        _vf_windows ~= vf_window;
    }

    void unregister( W os_window )
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;
        auto i = _os_windows.countUntil( os_window );
        _os_windows = _os_windows.remove( i );
        _vf_windows = _vf_windows.remove( i );
    }

    // 
    auto new_window(TW,ARGS...)( ARGS args )
    {
        auto window = new TW( args );
        register( window.hwnd, window );
        return window;
    }    
}
