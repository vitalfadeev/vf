module vf.input.cached_queue;


struct CachedQueue(Front,Queue)
{
    Front  front;
    Queue _queue;
    bool  _cached;

    void popFront() 
    {
        // get cached front first
        if ( !_queue.empty )
        {
            _queue.popFront();
             front  = _queue.front;
            _cached =  true;
        }
        else
            _cached = false;
    }

    bool empty() 
    { 
        if ( _cached )
            return false;

        return _queue.empty();
    }
}
