module vf.platforms.xcb.types;

version(XCB):
import std.traits;
import xcb.xcb;
public import vf.base.types;
import vf.platforms.xcb.px : PX;
import vf.traits;
import vf.platforms.xcb.event : Event, EVENT_TYPE;


alias SENSOR  = void delegate(              Event* event, EVENT_TYPE event_type );
alias SENSORF = void function( void* _this, Event* event, EVENT_TYPE event_type );
alias X       = short;
alias Y       = short;
alias W       = X;
alias H       = Y;

// for XCB functions
alias uint32_t = uint;
alias uint16_t = ushort;

//
class XCBException : Exception
{
    import xcb.xcb;

    this( string s, xcb_connection_t* c )
    {
        auto err = xcb_connection_has_error( c );

        super( xcb_error_to_string( err ) );
    }
}

string xcb_error_to_string( int err )
{
    switch ( err ) {
        case XCB_CONN_ERROR: 
            return ": [XCB_CONN_ERROR]: because of socket errors, pipe errors or other stream errors";
        case XCB_CONN_CLOSED_EXT_NOTSUPPORTED:
            return ": [XCB_CONN_CLOSED_EXT_NOTSUPPORTED]: when extension not supported";
        case XCB_CONN_CLOSED_MEM_INSUFFICIENT:
            return ": [XCB_CONN_CLOSED_MEM_INSUFFICIENT]: when memory not available";
        case XCB_CONN_CLOSED_REQ_LEN_EXCEED:
            return ": [XCB_CONN_CLOSED_REQ_LEN_EXCEED]: exceeding request length that server accepts";
        case XCB_CONN_CLOSED_PARSE_ERR:
            return ": [XCB_CONN_CLOSED_PARSE_ERR]: error during parsing display string";
        case XCB_CONN_CLOSED_INVALID_SCREEN:
            return ": [XCB_CONN_CLOSED_INVALID_SCREEN]: because the server does not have a screen matching the display";
        default:
            return "";
    }    
}

nothrow
void show_throwable( Throwable o )
{
    import std.stdio;
    import std.string;
    import std.utf;
    try { auto s = o.toString.toUTF16z; 
        writeln( "error: ", s );
    }
    catch (Throwable o) { /* MessageBox( null, "Window: o.toString error", "Error", MB_OK | MB_ICONEXCLAMATION );*/ }
}
