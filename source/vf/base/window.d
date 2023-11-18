module vf.base.window;


class BaseWindow(Event,EventType)
{
    alias THIS       = typeof(this);
    alias BaseWindow = typeof(this);

    //this(ARGS...)( ARGS args )
    //{
    //    _create_window( args );
    //    _create_renderer();
    //}

    void sense( Event* event, EventType event_type )
    //    this         event             event_type
    //    RDI          RSI               RDX
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


    void draw( Event* event, EventType event_type ) 
    {
        //
    }


    //// private
    //void _create_window(ARGS...)( ARGS args )
    //{
    //    //
    //}

    //void _create_renderer()
    //{
    //    //
    //}
}
