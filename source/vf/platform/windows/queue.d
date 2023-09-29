module vf.platform.windows.queue;

version (WINDOWS_NATIVE):
import core.sys.windows.windows;
import vf.types;


struct Queue
{
    MSG front;  // MSG

    pragma( inline, true )
    void popFront()
    {
        if ( GetMessage( &this.front, null, 0, 0 ) == 0 ) 
            if ( GetLastError() )
                throw new WindowsException( "Queue.popFront: " );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( front.message == WM_QUIT );
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( MSG m )
    {
        SendMessage( m.hwnd, m.message, m.wParam, m.lParam ); // The event is copied into the queue.
    }
}
