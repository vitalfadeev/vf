// recusive iterator (in depth)
struct Recursive(E)
{
    import std.range : empty, popFront, front;

    alias E_SLICE = E[];
    E_SLICE[] _stack;

    //@property 
    E    front() { return _stack.front.front; }
    E    moveFront() { ; }
    void popFront() { _stack.popFront(); }
    @property 
    bool empty() { return _stack.empty; }
    int  opApply(scope int delegate(E));
    int  opApply(scope int delegate(size_t, E));
}

// World
//   foreach( e ; World.enter )
//     ...
//void recursive_one(E)( E one, void delegate( E e ) dg )
//{
//    dg( e );

//    foreach( e; one.enter )
//        recursive_one( e, dg );
//}

// world
//  dg(world)
//  world on stack     - range (front,back)
//   go deep
//   e
//   dg(e)
//   e on stack        - range (front,back)
//     go deep
//     null
//     go up
//   pop from stack e  - range (front,back)
//   popFront()
//   e
//
// foreach_recursive()
//  range(front,back)[] stack
//  slice[a..b][]       stack
//  E[][]               stack
//  alias E_SLICE = E[]
//  E_SLICE[]           stack
