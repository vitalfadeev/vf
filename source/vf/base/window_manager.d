module vf.base.window_manager;

import vf.base.interfaces : IWindowManager;


// hwnd -> window
// window -> hwnd
class WindowManager(V,O) : IWindowManager!(V,O)
{
    O[] _os_windows;
    V[] _vf_windows;

    V vf_window( O os_window )
    {
        import std.algorithm.searching : countUntil;
        auto i = _os_windows.countUntil( os_window );

        return _vf_windows[i];
    }

    void register( O os_window, V vf_window )
    {
        _os_windows ~= os_window;
        _vf_windows ~= vf_window;
    }

    void unregister( O os_window )
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

    typeof(this) instance()
    {
        static typeof(this) _instance;
        
        if ( _instance is null )
            _instance = new typeof(this);

        return _instance;
    }
}


class ManagedWindow(WINDOW,OSWINDOW) : WINDOW
{
    this(ARGS...)( ARGS args )
    {
        super( args );
        WindowManager(WINDOW,OSWINDOW).instance.register( this.hwnd, this );
    }
}
