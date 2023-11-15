module vf.base.window;


class Window(Event,EVENT_TYPE)
{
    this(ARGS...)( ARGS args )
    {
        _create_window( args );
        _create_renderer();
    }

    void sense( Event* event, EVENT_TYPE event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
    {
        //
    }

    // private
    private
    void _create_window(ARGS...)( ARGS args )
    {
        //
    }


    void move_to_center()
    {
        //
    }


    void show()
    {
        //
    }


    private
    void _create_renderer()
    {
        //
    }
}
