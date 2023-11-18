module vf.platforms.xcb.types;

version(XCB):
import xcb.xcb;
public import vf.base.types;
import vf.platforms.xcb.event  : Event, EventType;
// for XCB functions
public import core.stdc.stdint : uint32_t;
public import core.stdc.stdint : uint16_t;

alias Sensor  = vf.base.types.Sensor!(Event,EventType);
alias X       = short;
alias Y       = short;
alias W       = short;
alias H       = short;
