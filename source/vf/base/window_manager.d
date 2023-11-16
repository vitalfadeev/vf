module vf.base.window_manager;

import vf.base.interfaces : IWindowManager;


// hwnd -> window
// window -> hwnd
class WindowManager(V,O,Event,EVENT_TYPE)
{
    O[] _os_windows;
    V[] _vf_windows;

    void sense( Event* event, EVENT_TYPE event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        //
    }

    V vf_window( O os_window )
    {
        import std.algorithm.searching : countUntil;
        auto i = _os_windows.countUntil( os_window );

        return _vf_windows[i];
    }

    void register( V vf_window, O os_window )
    {
        _vf_windows ~= vf_window;
        _os_windows ~= os_window;
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
}


//
class ManagedWindow(V,O,Event,EVENT_TYPE) : V
{
    this(ARGS...)( ARGS args )
    {
        super( args );
        WindowManager!(V,O,Event,EVENT_TYPE).instance.register( this, this.hwnd );
    }
}
