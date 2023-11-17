module vf.platforms.xcb.types;

version(XCB):
import xcb.xcb;
public import vf.base.types;
import vf.platforms.xcb.px     : PX;
import vf.platforms.xcb.event  : Event, EventType;
// for XCB functions
public import core.stdc.stdint : uint32_t;
public import core.stdc.stdint : uint16_t;


alias SENSOR  = void delegate(              Event* event, EventType event_type );
alias SENSORF = void function( void* _this, Event* event, EventType event_type );
alias X       = short;
alias Y       = short;
alias W       = short;
alias H       = short;
