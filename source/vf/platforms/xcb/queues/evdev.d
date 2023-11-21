module vf.platforms.xcb.queues.evdev;

version(XCB):
import xcb.xcb;
import std.range : front, empty, popFront;
public import vf.base.queue;
import vf.base.sensable          : SensAble;
import vf.platforms.xcb.platform : Platform;
import vf.platforms.xcb.event    : Event, EventType;


enum VfEventType : byte
{
    _       = 0,
    QUIT    = 1,
}

struct VfEvent
{
    VfEventType                type;
    SensAble!(Event,EventType) dst;
}

struct XcbEvent
{
    alias Timestamp = uint;  // xcb_timestamp_t = uint

    union {
        xcb_generic_event_t*           generic;
        xcb_key_press_event_t*         key_press;
        xcb_button_press_event_t*      button_press;
        xcb_motion_notify_event_t*     motion_notify;
        xcb_enter_notify_event_t*      enter_notify;
        xcb_focus_in_event_t*          focus_in;
        xcb_keymap_notify_event_t*     keymap_notify;
        xcb_expose_event_t*            expose;
        xcb_graphics_exposure_event_t* graphics_exposure;
        xcb_no_exposure_event_t*       no_exposure;
        xcb_visibility_notify_event_t* visibility_notify;
        xcb_create_notify_event_t*     create_notify;
        xcb_destroy_notify_event_t*    destroy_notify;
        xcb_unmap_notify_event_t*      unmap_notify;
        xcb_map_notify_event_t*        map_notify;
        xcb_map_request_event_t*       map_request;
        xcb_reparent_notify_event_t*   reparent_notify;
        xcb_configure_notify_event_t*  configure_notify;
        xcb_configure_request_event_t* configure_request;
        xcb_gravity_notify_event_t*    gravity_notify;
        xcb_resize_request_event_t*    resize_request;
        xcb_circulate_notify_event_t*  circulate_notify;
        xcb_property_notify_event_t*   property_notify;
        xcb_selection_clear_event_t*   selection_clear;
        xcb_selection_request_event_t* selection_request;
        xcb_selection_notify_event_t*  selection_notify;
        xcb_colormap_notify_event_t*   colormap_notify;
        xcb_client_message_event_t*    client_message;
        xcb_mapping_notify_event_t*    mapping_notify;
        xcb_ge_generic_event_t*        ge_generic;
    }

    auto type() @property
    {
        return generic.response_type;
    }
}

struct EvdevEvent
{
    InputEvent input_event;

    auto type() @property
    {
        return input_event.type;
    }

    struct InputEvent {
        Timeval time;  // long, long
        ushort  type;
        ushort  code;
        uint    value;

        struct Timeval
        {
            time_t      tv_sec;
            suseconds_t tv_usec;
        }

        alias time_t      = long;  // 'long' on 64-bit systen
        alias suseconds_t = long;
    }
}

//
enum EventSource : ubyte
{
    _     = 0,
    VF    = 1,
    XCB   = 2,
    EVDEV = 3,
}

struct Event
{
    EventSource    source;
    union {
        VfEvent    vf;
        XcbEvent   xcb;
        EvdevEvent evdev;
    }

    alias Timestamp = typeof( EvdevEvent.input_event.time.tv_sec );
    Timestamp timestamp()
    {
        final
        switch ( source )
        {
            case EventSource._     : return 0;
            case EventSource.VF    : return vf.timestamp;
            case EventSource.XCB   : return xcb.timestamp;
            case EventSource.EVDEV : return evdev.timestamp;
        }
    }

    import std.traits : Largest;
    alias T_type = Largest!( typeof(vf.type), typeof(xcb.type), typeof(evdev.type) );
    T_type type()
    {
        final
        switch ( source )
        {
            case EventSource._     : return 0;
            case EventSource.VF    : return vf.type;
            case EventSource.XCB   : return xcb.type;
            case EventSource.EVDEV : return evdev.type;
        }
    }

    SensAble!(Event,EventType) dst()
    {
        final
        switch ( source )
        {
            case EventSource._     : return null;
            case EventSource.VF    : return vf.dst;
            case EventSource.XCB   : return null;
            case EventSource.EVDEV : return null;
        }
    }

    //
    bool is_draw()
    {
        final
        switch ( source )
        {
            case EventSource._     : return false;
            case EventSource.VF    : return false;
            case EventSource.XCB   : return ( xcb.generic.response_type == XCB_DRAW );
            case EventSource.EVDEV : return false;
        }
    }

    bool is_quit()
    {
        return ( source == EventSource.VF && vf.type == VfEventType.QUIT );
    }

    //
    string toString()
    {
        import std.format : format;
        return format!"Event.%s( 0x%04X )"( source, type );
    }
}


struct VfQueue
{
    VfEvent[] _events;
    alias _events this;

    import std.range;
    alias front    = std.range.front;
    alias empty    = std.range.empty;
    alias popFront = std.range.popFront;
}


struct EvdevQueue
{
    EvdevEvent* front;

    CachedDeviceQueue[] _queues;

    this( string[] devices )
    {
        foreach( device_file_name; devices )
            _queues ~= CachedDeviceQueue( device_file_name );
    }

    void popFront()
    {
        alias Timestamp = typeof( EvdevEvent.input_event.time.tv_sec );
        
        Timestamp min_timestamp;
        size_t    min_queue_i;

        foreach ( i, q; _queues )
            if ( !q.empty )
                if ( q.front.input_event.time.tv_sec < min_timestamp )
                {
                    min_timestamp = q.front.input_event.time.tv_sec;
                    min_queue_i   = i;
                    break;
                }

        //
        if ( min_timestamp )
        {        
            auto queue = _queues[ min_queue_i ];
            front = &queue.front;
            queue.popFront();
        }
    }
    
    bool empty()
    {
        import std.algorithm.searching : all;
        return all("empty")( _queues );
    }
}


struct CachedDeviceQueue
{
    EvdevEvent  front;
    DeviceQueue device;
    bool       _cached;

    void popFront() 
    {
        // get cached front first
        if ( !device.empty )
        {
            device.popFront();
            front = device.front;
            _cached = true;
        }
        else
            _cached = false;
    }

    bool empty() 
    { 
        if ( _cached )
            return false;

        return device.empty();
    }
}

struct DeviceQueue
{
    EvdevEvent front;

    string    _device;  // "/dev/input/event5"
    int       _fd;    


    this( string device )
    {
        _device = device;
        _init();
    }

    void _init()
    {
        import std.string           : toStringz;
        import core.sys.posix.fcntl : open;
        import core.sys.posix.fcntl : O_RDONLY;
        import core.sys.linux.fcntl : fcntl;
        import core.sys.posix.fcntl : O_NONBLOCK;
        import core.sys.posix.fcntl : F_SETFL;
        import core.sys.posix.fcntl : F_GETFL;

        if ( ( _fd = open( _device.toStringz, O_RDONLY ) ) < 0 ) {
            // err
        }

        // set the file description to non blocking
        int flags = fcntl( fd, F_GETFL, 0 );
        fcntl( fd, F_SETFL, flags | O_NONBLOCK );

        // can also use select/poll to check to see if data is available
    }

    void popFront()
    {
        import core.sys.linux.stdio : read;

        auto size = read( _fd, &front.input_event, input_event.sizeof );

        if ( size < front.input_event.sizeof )
            throw new InputException( format!"error reading: %s: expected %u bytes, got %u\n"( _device, front.input_event.sizeof, size ) );        
    }

    bool empty()
    { 
        import core.sys.posix.poll  : poll;
        import core.sys.linux.errno : errno;

        // n = total number of file descriptors that have events 
        int n = poll(
            &_fd, // file descriptors
            1,    // number of file descriptors
            0     // timeout ms
        );

        // no events
        if ( n == 0 )
            return true;

        // check error
        if ( n < 0 )
        {
            // soft error - no events
            if ( errno == EAGAIN || errno == EINTR )
               return true;
            else
                throw new InputException( "EINVAL" );
        }

        return false;  // has events
    }
}
