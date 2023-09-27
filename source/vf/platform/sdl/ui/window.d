module vf.platform.sdl.ui.window;

version(SDL):
import bindbc.sdl;
import vf.game;
import vf.types;
import vf.cls.o : O;
import vf.cls.o : IVAble, ILaAble, ISenseAble, IStateAble;
import vf.cls.o : VAble,  LaAble,  SenseAble,  StateAble;


alias Window = WindowSensor;

class WindowSensor : ISenseAble, IVAble, ILaAble
{
    alias T = typeof(this);

    mixin SenseAble!T;
    mixin LaAble!T;
    mixin VAble!T;

    // Custom memory
    SDL_Window*   window;
    SDL_Renderer* renderer;


    this( PX size=PX(640,480), string name="SDL2 Window" )
    {
        _create_window( size, name );
        _create_renderer();
    }


    // ISenseAble
    pragma( inline, true )
    void on_DT_MOUSEBUTTONDOWN( D d )
    {
        if ( d.button.button == SDL_BUTTON_LEFT )  // sub sensor
        {
            game.pool ~= DT_MOUSE_LEFT_PRESSED;    // action
            game.pool ~= D_LA( pxpx );             // action
        }
    }

    pragma( inline, true )
    void on_DT_LA( D d )
    {
        auto pxpx = d.to!PXPX;
        la();
    }


    // ILaAble
    void la( Renderer renderer ) 
    {
        //
    }

    void la_borders()
    {
        la_cola( 0xFF_FF_FF_FF );
        la_rect( 0, 0, _px );
    }

    void la_cola( uint rgba )
    {
        ubyte r = ( rgba & 0xFF000000 ) >> 24;
        ubyte g = ( rgba & 0x00FF0000 ) >> 16;
        ubyte b = ( rgba & 0x0000FF00 ) >> 8;
        ubyte a = ( rgba & 0x000000FF );
        SDL_SetRenderDrawColor( renderer, r, g, b, a );
    }

    void la_rect( M16 x, M16 y, PX size )
    {
        // inner rect
        //   0,10 = line 0..9 including 9

        SDL_Rect r;
        r.x = x;
        r.y = y;
        r.w = size.x;
        r.h = size.y;

        SDL_RenderDrawRect( renderer, &r );
    }


    // LIGHT
    // la( xy )               // point  xy
    // la( xy[] )             // points xy[] = ( xy.length, xy.ptr )
    //
    // GO LIGHT
    // la( xy, _xy )        // line  xy to _xy
    // la( xy, _xy, __xy )  // line  xy to _xy to __xy
    // la( xy[] )           // lines xy[] = ( xy.length, xy.ptr )
    void la()
    {
        la_borders();
        la_v();
        SDL_RenderPresent( renderer );
    }

    void la_v()
    {
        foreach( o; this.v )
            o.la( Renderer( renderer ) );
    }

    // oxox, px_, _px, pxpx
    auto oxox()
    {
        return OXOX( ox_, _ox ); // M16,M16,M16,M16
    }

    auto ox_()
    {
        return px_.to!OX; 
    }

    auto _ox()
    {
        return _px.to!OX; 
    }

    auto px_()
    {
        PX px;

        SDL_GetWindowPosition( window, &px.x, &px.y );

        return px; // M16,M16,M16,M16
    }


    auto _px()
    {
        PX px;

        SDL_GetWindowSizeInPixels( window, &px.x, &px.y );

        return px; // M32,M32 -> F16.16,F16.16
    }

    auto pxpx()
    {
        return PXPX( px_, _px ); // M16,M16,M16,M16
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
