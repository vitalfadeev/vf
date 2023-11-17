module vf.base.types;

alias M       = void;
alias M1      = bool;
alias M8      = ubyte;
alias M16     = ushort;
alias M32     = uint;
alias M64     = ulong;
alias MPTR    = void*;

alias SENSOR(Event,EventType)  = void delegate(              Event* event, EventType event_type );
alias SENSORF(Event,EventType) = void function( void* _this, Event* event, EventType event_type );
