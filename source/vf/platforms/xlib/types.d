module vf.platforms.xlib.types;

version (XLIB):
import std.traits;
import xcb.xcb;
import vf.traits;


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

//
PX to_px( WX wx )
{
    PX px;
    px.x = wx.x;
    px.y = wx.y;
    return px;
}


//
class LinuxX11Exception : Exception
{
    this( string s )
    {
        _super( s );
    }
}

class LinuxX11XCBException : Exception
{
    import xcb.xcb;

    this( string s, xcb_connection_t* c )
    {
        auto err = xcb_connection_has_error(c);
        switch ( err ) {
            case XCB_CONN_ERROR: 
                s ~= ": [XCB_CONN_ERROR]: because of socket errors, pipe errors or other stream errors"; break;
            case XCB_CONN_CLOSED_EXT_NOTSUPPORTED:
                s ~= ": [XCB_CONN_CLOSED_EXT_NOTSUPPORTED]: when extension not supported"; break;
            case XCB_CONN_CLOSED_MEM_INSUFFICIENT:
                s ~= ": [XCB_CONN_CLOSED_MEM_INSUFFICIENT]: when memory not available"; break;
            case XCB_CONN_CLOSED_REQ_LEN_EXCEED:
                s ~= ": [XCB_CONN_CLOSED_REQ_LEN_EXCEED]: exceeding request length that server accepts"; break;
            case XCB_CONN_CLOSED_PARSE_ERR:
                s ~= ": [XCB_CONN_CLOSED_PARSE_ERR]: error during parsing display string"; break;
            case XCB_CONN_CLOSED_INVALID_SCREEN:
                s ~= ": [XCB_CONN_CLOSED_INVALID_SCREEN]: because the server does not have a screen matching the display"; break;
            default:
        }

        _super( s );
    }
}

nothrow
void show_throwable( Throwable o )
{
    import std.string;
    import std.utf;
    try { auto s = o.toString.toUTF16z; 
        writeln( "error: ", s );
    }
    catch (Throwable o) { MessageBox( NULL, "Window: o.toString error", "Error", MB_OK | MB_ICONEXCLAMATION ); }
}

alias LaType = ubyte;

struct La
{
    xcb_generic_la_t _super;
    alias _super this;
}

alias ERESULT = void;
