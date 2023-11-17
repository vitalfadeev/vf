module vf.platforms.xcb.types;

version(XCB):
import xcb.xcb;
public import vf.base.types;
import vf.platforms.xcb.px     : PX;
import vf.platforms.xcb.event  : Event, EVENT_TYPE;
// for XCB functions
public import core.stdc.stdint : uint32_t;
public import core.stdc.stdint : uint16_t;


alias SENSOR  = void delegate(              Event* event, EVENT_TYPE event_type );
alias SENSORF = void function( void* _this, Event* event, EVENT_TYPE event_type );
alias X       = short;
alias Y       = short;
alias W       = short;
alias H       = short;

//
class XCBException : Exception
{
    this( string s, xcb_connection_t* c )
    {
        super( xcb_error_to_string( xcb_connection_has_error( c ) ) );
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
    import std.stdio : writeln;

    try { 
        writeln( "error: ", o.toString );
    }
    catch (Throwable o) { 
        import core.stdc.stdio : printf;
        printf( "show_throwable: o.toString error" );
    }   
}
