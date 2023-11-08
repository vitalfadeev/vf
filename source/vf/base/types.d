module vf.base.types;

alias M       = void;
alias M1      = bool;
alias M8      = ubyte;
alias M16     = ushort;
alias M32     = uint;
alias M64     = ulong;
alias MPTR    = void*;

alias SENSOR(Event,EVENT_TYPE)  = void delegate(              Event* event, EVENT_TYPE event_type );
alias SENSORF(Event,EVENT_TYPE) = void function( void* _this, Event* event, EVENT_TYPE event_type );

