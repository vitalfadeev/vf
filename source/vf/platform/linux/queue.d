module vf.platform.linux.queue;


version (LINUX_X11):
import vf.types;


struct Queue
{
    Display* X_display=0;
    XEvent   front;

    pragma( inline, true )
    void popFront()
    {
        XNextEvent( x_display, &front );
        switch (x_event.type)
        {
            case KeyPress:
                break;

            case KeyRelease:
                break;

            case ButtonPress:
                break;

            case ButtonRelease:
                break;

            case MotionNotify:
                break;

            case Expose:
                break;

            case ConfigureNotify:
                break;

            default:
                //if ( doShm && X_event.type == X_shmeventtype ) 
                //    shmFinished = true;
                break;
        }
    }

    pragma( inline, true )
    bool empty()
    {
        return XPending( x_display );
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    //pragma( inline, true )
    //void opOpAssign( string op : "~" )( SDL_EventType t )
    //{
    //}
}
