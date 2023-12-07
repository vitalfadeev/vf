module vf.platforms.windows.queue;

version (WINDOWS):
import core.sys.windows.windows;
import vf.platforms.windows.la : La;
import vf.platforms.windows.types : WindowsException;


struct Queue
{
    La _la;  // MSG
    
    pragma( inline, true )
    @property
    La* front() { return &_la; };  // MSG*

    pragma( inline, true )
    void popFront()
    {
        if ( GetMessage( &_la.msg, null, 0, 0 ) == 0 ) 
            if ( GetLastError() )
                throw new WindowsException( "Queue.popFront: " );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( _la.msg.message == WM_QUIT );
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( MSG m )
    {
        SendMessage( m.hwnd, m.message, m.wParam, m.lParam ); // The la is copied into the queue.
    }
}
