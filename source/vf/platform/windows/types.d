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
alias SENSOR  = void delegate( Event m );
alias SENSORF = void function( Event m );
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


struct Event 
{
    UINT _super;
    alias _super this;
}

struct EventCode
{
    WPARAM _super;
    alias _super this;
}

struct EventValue
{
    LPARAM _super;
    alias _super this;
}

alias LRESULT = core.sys.windows.windows.LRESULT;
alias HDC = core.sys.windows.windows.HDC;
alias PAINTSTRUCT = core.sys.windows.windows.PAINTSTRUCT;
alias BeginPaint = core.sys.windows.windows.BeginPaint;
alias EndPaint = core.sys.windows.windows.EndPaint;
alias MessageBox = core.sys.windows.windows.MessageBox;
alias MB_OK = core.sys.windows.windows.MB_OK;
alias MB_ICONEXCLAMATION = core.sys.windows.windows.MB_ICONEXCLAMATION;
alias NULL = core.sys.windows.windows.NULL;