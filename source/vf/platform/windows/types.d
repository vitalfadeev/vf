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
        super( GetLastError(), format!"%s(%x): %s"( error_message, code, msg ) );
    }

    private
    string error_message()
    {
        import std.string;
        
        char[] buffer = new char[2048];
        buffer[0] = '\0';

        FormatMessageA( FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ARGUMENT_ARRAY,
                       null,
                       GetLastError(),
                       LANG_NEUTRAL,
                       buffer.ptr,
                       cast(uint)buffer.length,
                       cast(char**)["\0".ptr].ptr);

        return buffer.ptr.fromStringz.idup;
    }
}
