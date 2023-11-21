module vf.input.vf.queue;

import vf.input.vf.event : VfEvent;


struct VfQueue
{
    VfEvent[] _events;
    alias _events this;

    import std.range;
    alias front    = std.range.front;
    alias empty    = std.range.empty;
    alias popFront = std.range.popFront;
}
