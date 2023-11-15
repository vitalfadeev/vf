module vf.base.oswindow;


class OSWindow(HWND,Event,EVENT_TYPE)
{
    HWND hwnd;

    void sense( Event* event, EVENT_TYPE event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        //
    }
}
