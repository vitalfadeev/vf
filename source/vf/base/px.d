module vf.base.px;


// Coordinates in Raster
struct BasePX(X,Y)
{
    alias TBasePX = BasePX!(X,Y);

    X x;  // or vector!(xy)
    Y y;  //

    TBasePX opBinary(string op:"-")( PX b )
    {
        import std.conv : to;
        return 
            TBasePX( 
                (x - b.x).to!X, 
                (y - b.y).to!Y
            );
    }

    TBasePX opBinary(string op:"+")( TBasePX b )
    {
        import std.conv : to;
        return 
            TBasePX( 
                (x + b.x).to!X, 
                (y + b.y).to!Y
            );
    }

    TBasePX opBinary(string op:"/")( int b )
    {
        return TBasePX( x/b, y/b );
    }
}
