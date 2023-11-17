module vf.platforms.xcb.exception;

version(XCB):
import xcb.xcb;


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
