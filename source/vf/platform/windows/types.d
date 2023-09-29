module vf.platform.windows.types;

version (WINDOWS_NATIVE):
import core.sys.windows.windows;
import std.traits;
import std.windows.syserror;
import vf.traits;


alias M       = void;
alias M1      = bool;
alias M8      = ubyte;
alias M16     = ushort;
alias M32     = uint;
alias M64     = ulong;
alias MPTR    = void*;
alias SENSOR  = void delegate( MSG m );
alias SENSORF = void function( MSG m );
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

//
class WindowsException : std.windows.syserror.WindowsException
{
    this( string msg )
    {
        super( GetLastError(), msg );
    }
}


struct Message 
{
    UINT _super;
    alias _super this;
}
