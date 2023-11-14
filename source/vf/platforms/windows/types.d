module vf.platforms.windows.types;

version (WINDOWS):
import core.sys.windows.windows;
import std.traits;
import std.windows.syserror;
import vf.platforms.windows.event;
import vf.traits;
public import vf.base.types;


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
struct WX
{
    X x;
    Y y;
}


PX to_px( WX wx )
{
    PX px;
    px.x = wx.x;
    px.y = wx.y;
    return px;
}


//
class WindowsException : std.windows.syserror.WindowsException
{
    this( string msg )
    {
        super( GetLastError(), msg );
    }
}

nothrow
void show_throwable( Throwable o )
{
    import std.string;
    import std.utf;
    try { auto s = o.toString.toUTF16z; 
        MessageBox( NULL, s, "Error", MB_OK | MB_ICONEXCLAMATION );
    }
    catch (Throwable o) { MessageBox( NULL, "Window: o.toString error", "Error", MB_OK | MB_ICONEXCLAMATION ); }
}


alias LRESULT            = core.sys.windows.windows.LRESULT;
alias HDC                = core.sys.windows.windows.HDC;
alias PAINTSTRUCT        = core.sys.windows.windows.PAINTSTRUCT;
alias BeginPaint         = core.sys.windows.windows.BeginPaint;
alias EndPaint           = core.sys.windows.windows.EndPaint;
alias MessageBox         = core.sys.windows.windows.MessageBox;
alias MB_OK              = core.sys.windows.windows.MB_OK;
alias MB_ICONEXCLAMATION = core.sys.windows.windows.MB_ICONEXCLAMATION;
alias NULL               = core.sys.windows.windows.NULL;
