module vf.base.wx;


// Coordinates in World
struct WX(X,Y)
{
    X x;  // or vector!(xy)
    Y y;  //

    viud opOpAssign( string op : "+" )( WX!(X,Y) b )
    {
        x += b.x;
        y += b.y;
    }
}
