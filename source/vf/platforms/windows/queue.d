module vf.platforms.windows.queue;

version (WINDOWS):
import core.sys.windows.windows;
import vf.platforms.windows.event : Event;
import vf.platforms.windows.types : WindowsException;


struct Queue
{
    Event front;  // MSG

    pragma( inline, true )
    void popFront()
    {
        if ( GetMessage( &this.front.msg, null, 0, 0 ) == 0 ) 
            if ( GetLastError() )
                throw new WindowsException( "Queue.popFront: " );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( front.msg.message == WM_QUIT );
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( MSG m )
    {
        SendMessage( m.hwnd, m.message, m.wParam, m.lParam ); // The event is copied into the queue.
    }
}
