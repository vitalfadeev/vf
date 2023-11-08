module vf.platforms.windows.queue;

version (WINDOWS):
import core.sys.windows.windows;
import vf.platforms.windows.event : Event;
import vf.platforms.windows.types : WindowsException;


struct Queue
{
    Event _event;  // MSG
    
    pragma( inline, true )
    @property
    Event* front() { return &_event; };  // MSG*

    pragma( inline, true )
    void popFront()
    {
        if ( GetMessage( &_event.msg, null, 0, 0 ) == 0 ) 
            if ( GetLastError() )
                throw new WindowsException( "Queue.popFront: " );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( _event.msg.message == WM_QUIT );
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( MSG m )
    {
        SendMessage( m.hwnd, m.message, m.wParam, m.lParam ); // The event is copied into the queue.
    }
}
