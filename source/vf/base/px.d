module vf.base.px;


// Coordinates in Raster
struct PX(X,Y)
{
    X x;  // or vector!(xy)
    Y y;  //

    PX opBinary(string op:"-")( PX b )
    {
        import std.conv : to;
        return 
            PX( 
                (x - b.x).to!X, 
                (y - b.y).to!Y
            );
    }

    PX opBinary(string op:"+")( PX b )
    {
        import std.conv : to;
        return 
            PX( 
                (x + b.x).to!X, 
                (y + b.y).to!Y
            );
    }

    PX opBinary(string op:"/")( int b )
    {
        return PX( x/b, y/b );
    }
}
