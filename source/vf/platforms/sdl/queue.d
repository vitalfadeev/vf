module vf.platforms.sdl.queue;

version (SDL):
import bindbc.sdl;
import vf.types;


struct Queue
{
    SDL_La front;

    pragma( inline, true )
    void popFront()
    {
        if ( SDL_WaitLa( cast( SDL_La* )&this.front ) == 0 )
            throw new SDLException( "Queue.popFront: " );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( front.type == SDL_QUIT );
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    pragma( inline, true )
    void opOpAssign( string op : "~" )( SDL_LaType t )
    {
        SDL_La la;
        la.type = t;
        SDL_PushLa( &la ); // The la is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D d )
    {
        SDL_PushLa( cast(SDL_La*)&d ); // The la is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( SDL_UserLa d )
    {
        SDL_PushLa( cast(SDL_La*)&d ); // The la is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D_LA d )
    {
        SDL_PushLa( cast(SDL_La*)&d ); // The la is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D_KEY_PRESSED d )
    {
        SDL_PushLa( cast(SDL_La*)&d ); // The la is copied into the queue.
    }
}
