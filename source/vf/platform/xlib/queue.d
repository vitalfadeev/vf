module vf.platform.linux.queue_xlib;

version (LINUX_X11_xlib):
import vf.types;
import x11.xlib;


struct Queue
{
    XEvent front;

    Display *display;
    Window window;
    int s;

    this()
    {
        // open connection to the server
        display = XOpenDisplay(NULL);
        if (display == NULL)
        {
            fprintf(stderr, "Cannot open display\n");
            exit(1);
        }
     
        s = DefaultScreen(display);
     
        // create window
        window = XCreateSimpleWindow(display, RootWindow(display, s), 10, 10, 200, 200, 1,
                                     BlackPixel(display, s), WhitePixel(display, s));
     
        // select kind of events we are interested in
        XSelectInput(display, window, ExposureMask | KeyPressMask);
     
        // map (show) the window
        XMapWindow(display, window);    
    }

    ~this()
    {
        // close connection to the server
        XCloseDisplay(display);        
    }

    void popFront()
    {
        XNextEvent(display, &front);
    }

    bool empty()
    {
        return front is null;
    }
}
