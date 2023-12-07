module vf.input.la;


// evdev
//   include/uapi/linux/input-la-codes.h
//     EV_SYN, EV_KEY, EV_REL, EV_ABS, EV_MSC, EV_SW, EV_LED, EV_SND, EV_REP, EV_FF, EV_PWR, EV_FF_STATUS
//   include/winuser.h 
//     WM_USER, WM_APP
enum ushort EV_USR   = 0x0400;      // WM_USER  0x0400..0x7FFF
enum ushort EV_APP   = 0x8000;      // WM_APP   0x8000..0xBFFF
enum ushort EV_TIMER = EV_APP + 0x10;
enum ushort EV_DBUS  = EV_APP + 0x20;
enum ushort EV_XCB   = EV_APP + 0x40;

// catch by...
//   EV_APP_ELEMENT_UPDATED
//
// catch by Focus Manager
//   EV_APP_ELEMENT_FOCUSED
//   EV_APP_ELEMENT_UNFOCUSED
//
// catch by...
//   EV_APP_ELEMENT_MOUSE_IN
//   EV_APP_ELEMENT_MOUSE_OUT
//   EV_APP_ELEMENT_MOUSE_OVER
//
// catch by Window Manager
//   EV_WINDOW_ACTIVATED
//   EV_WINDOW_DEACTIVATED
//
// catch by ...
//   EV_KEY...



struct Timeval
{
    time_t      tv_sec;
    suseconds_t tv_usec;
}

alias time_t      = ulong;  // c_long = 'ulong' on 64-bit systen
alias suseconds_t = ulong;


struct LaType
{                 //        x86_64   x86_32
    ushort type;  //  16  | = RDX  | = EAX   = ( source + type + sybtype )
    ushort code;  //  16  |        |
    uint   value; //  32  |  
}

version(_stub_64_)
void sense( La* la, LaType la_type )
// on x86_64 - all in registers
//    this         la            la_type  ...  ...  ...
//    RDI          RSI              RDX         RCX  R8   R9
// vs x86_32 - all on stack
//    la_type, la, this, ret
// vs D-calling - last-parameter in EAX
//    this, la, ret
//    EAX = la_type
// vs custom calling          ?
//    ...128-bit register use ?
{
    // source 
    //   0x0000..0x03FF =  os ( windows, linux, evdev, dbus )
    //   0x0400..0x7FFF = usr 
    //   0x8000..0xFFFF = app ( app, app_timer )
}



struct Game
{
    void go()
    {
        foreach ( e; queue )
            sensors.sense( e, e.la_type );
    }

    void world_sense( La* la, LaType la_type )
    {
        switch ( la_type.type ) {
            case EV_KEY: world.focus_router.sense(...); break;    // route to focused element
            case EV_REL: world.cursor_router.sense(...); break;   // route to element under cursor
            case EV_APP: world.element_router.sense(...); break;  // verify element, route to element
            default:
        }
    }

    void element_sense( La* la, LaType la_type )
    {
        switch ( la_type.type ) {
            case EV_KEY: switch( la_type.code ) {
                case KEY_UP:   break;
                case KEY_DOWN: break;
                default: break; break; }
            case EV_REL: switch( la_type.code ) {
                case REL_WHEEL: break;
                default: break; break; }
            case EV_APP: switch( la_type.code ) {
                case APP_ELEMENT_UPDATE: break;
                default: break; break; }
            default:
        }
    }
}

struct Queue
{
    La _la;
}



struct La
{
    Timeval    timeval;   // ulong
    LaType  la_type;  // ulong/uint/ushort/...: size for be placed in CPU Register
    Value      value;

    //
    LaSourceType type;
    union {                 //      M8   M8     M16 
        AppLa    app;    //      
        XcbLa    xcb;    //      type detail sequence time
        EvdevLa  evdev;  // time type        code     value
        //TimerLa  timer;  //      
        //DbusLa   dbus;   //      
    }                       
    //Device          device;

    alias LaType = .LaType;

    Timestamp timestamp()
    {
        final
        switch ( source )
        {
            case LaSourceType._     : return 0;
            case LaSourceType.APP   : return app.timestamp;
            case LaSourceType.XCB   : return xcb.timestamp;
            case LaSourceType.EVDEV : return evdev.timestamp;
        }
    }

    LaType la_type()
    {
        final
        switch ( source )
        {
            case LaSourceType._     : return 0;
            case LaSourceType.APP   : return app.type;
            case LaSourceType.XCB   : return xcb.type;
            case LaSourceType.EVDEV : return evdev.type;
        }
    }

    SensAble!(La,LaType) dst()
    {
        final
        switch ( source )
        {
            case LaSourceType._     : return null;
            case LaSourceType.APP   : return app.dst;
            case LaSourceType.XCB   : return null;
            case LaSourceType.EVDEV : return null;
        }
    }

    //
    bool is_draw()
    {
        final
        switch ( source )
        {
            case LaSourceType._     : return false;
            case LaSourceType.APP   : return false;
            case LaSourceType.XCB   : return ( xcb.generic.response_type == XCB_DRAW );
            case LaSourceType.EVDEV : return false;
        }
    }

    bool is_quit()
    {
        return ( source == LaSourceType.APP && app.type == AppLaType.QUIT );
    }

    //
    string toString()
    {
        import std.format : format;
        return format!"La.%s( 0x%04X )"( source, type );
    }
}


enum LaSourceType : ubyte
{
    _     = 0,
    APP   = 1,
    XCB   = 2,
    EVDEV = 3,
}


struct Device
{
    DeviceType type;
    union {
        MouseDevice    mouse;
        KeyboardDevice keyboard;
    }
}

enum DeviceType : ubyte
{
    _        = 0,
    MOUSE    = 1,
    KEYBOARD = 2,
}


struct MouseDevice
{
    //
}

struct KeyboardDevice
{
    //
}


//alias Element = vf.base.element.Element!(La,LaType,WX);
