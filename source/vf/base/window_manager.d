module vf.base.window_manager;


// hwnd -> window
// window -> hwnd
class BaseWindowManager(V,O,Event,EventType)
{
    static O[] _os_windows;
    static V[] _vf_windows;

    void sense( Event* event, EventType event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        //
    }

    static 
    V vf_window( O os_window )
    {
        import std.algorithm.searching : countUntil;
        auto i = _os_windows.countUntil( os_window );

        return _vf_windows[i];
    }

    static 
    void register( V vf_window, O os_window )
    {
        _vf_windows ~= vf_window;
        _os_windows ~= os_window;
    }

    static 
    void unregister( O os_window )
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;
        auto i = _os_windows.countUntil( os_window );
        _os_windows = _os_windows.remove( i );
        _vf_windows = _vf_windows.remove( i );
    }
}
