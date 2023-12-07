module vf.base.game;


template 
BaseGame (Queue,Sensors...) 
    // if Queue has 'instance'
    // if Queue is Range
    // if Queue.front has 'type'
    // if each Sensors is delegate(LaType)
{
    void 
    go () {
        auto queue = Queue.instance;

        foreach( ref la; queue )
            sense( la.type );
    }

    void 
    sense (LaType)(LaType la_type) {
        static foreach( s; Sensors )
            s( la_type );  // delegate
    }

    void
    aut (T)(T aut_code=0) {
        //
    }
}

