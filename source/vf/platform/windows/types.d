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

struct PX
{
    ushort x;
    ushort y;
}

//
class WindowsException : std.windows.syserror.WindowsException
{
    this( string msg )
    {
        import std.format;
        super( GetLastError(), format!"%s(%x): %s"( sysErrorString( GetLastError() ), GetLastError(), msg ) );
    }
}
