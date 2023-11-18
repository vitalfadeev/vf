module vf.base.types;

alias M       = void;
alias M1      = bool;
alias M8      = ubyte;
alias M16     = ushort;
alias M32     = uint;
alias M64     = ulong;
alias MPTR    = void*;

alias Sensor(Event,EventType) = void delegate( Event* event, EventType event_type );
