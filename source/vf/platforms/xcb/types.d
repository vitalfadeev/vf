module vf.platforms.xcb.types;

version(XCB):
import xcb.xcb;
public import vf.base.types;
import vf.platforms.xcb.la  : La, LaType;
// for XCB functions
public import core.stdc.stdint : uint32_t;
public import core.stdc.stdint : uint16_t;

alias Sensor  = vf.base.types.Sensor!(La,LaType);
alias X       = short;
alias Y       = short;
alias W       = short;
alias H       = short;
