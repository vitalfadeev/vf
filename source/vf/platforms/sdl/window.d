module vf.platforms.sdl.window;

version(SDL):
import bindbc.sdl;
import vf.game;
import vf.types;


class Window
{
    alias THIS = typeof(this);

    // Custom memory
    SDL_Window*   window;
    SDL_Renderer* renderer;


    this( PX size=PX(640,480), string name="SDL2 Window", int cmd_show=1 )
    {
        _create_window( size, name );
        _create_renderer();
    }


    //
    LRESULT event( Event e, EventCode code=EventCode(), EventValue value=EventValue() ) 
    {
        return 0;
    }

    auto ref move_to_center()
    {
        return this;
    }

    auto ref show()
    {
        return this;
    }


    // private
    private
    void _create_window( PX size, string name )
    {
        import std.string;

        // Window
        window = 
            SDL_CreateWindow(
                name.toStringz,
                SDL_WINDOWPOS_CENTERED,
                SDL_WINDOWPOS_CENTERED,
                size.x, size.y,
                0
            );

        if ( !window )
            throw new SDLException( "create_window" );

        // Update
        SDL_UpdateWindowSurface( window );
    }


    private
    void _create_renderer()
    {
        renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_SOFTWARE );
    }
}


LRESULT auto_route_event(THIS)( THIS This, Event e, EventCode code, EventValue value )
{
    import std.traits;
    import std.string;
    import std.format;

    // on_
    static foreach( m; __traits( allMembers, THIS ) )
        static if ( isCallable!(__traits(getMember, THIS, m)) )
            static if ( m.startsWith( "on_" ) )
                if ( e.type == mixin( m[3..$] ) )
                    return __traits(getMember, This, m)( e, code, value ); 

    return 0;
}
