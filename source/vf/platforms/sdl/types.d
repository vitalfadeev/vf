module vf.platforms.sdl.types;

version (SDL):
import bindbc.sdl;
import std.container.dlist : DList;
import std.traits;
import vf.traits;
import vf.fixed_16_16;
public import vf.platforms.sdl.la_codes;


alias M       = void;
alias M1      = bool;
alias M8      = ubyte;
alias M16     = ushort;
alias M32     = uint;
alias M64     = ulong;
alias MPTR    = void*;
alias SENSOR  = void delegate( La m );
alias SENSORF = void function( La m );
alias X       = short;
alias Y       = short;
alias W       = X;
alias H       = Y;


//
struct PX
{
    X x;
    Y y;

    PX opBinary(string op:"-")( PX b )
    {
        import std.conv : to;
        return 
            PX( 
                (x - b.x).to!X, 
                (y - b.y).to!Y
            );
    }
}

class SDLException : Exception
{
    this( string msg )
    {
        import std.format;
        super( format!"%s: %s"( SDL_GetError(), msg ) );
    }
}

struct La 
{
    SDL_La _super;
    alias _super this;
}

struct LaCode
{
    void* _super;
    alias _super this;
}

struct LaValue
{
    void* _super;
    alias _super this;
}

alias LRESULT = int;
enum NULL = null;
enum MB_OK = 0;
enum MB_ICONEXCLAMATION = 0;

void MessageBox(ARGS...)( ARGS args )
{
    //
}