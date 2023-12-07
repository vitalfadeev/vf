module vf.platforms.windows.world;

version(WINDOWS):
import core.sys.windows.windows;
import vf.base.world   : BaseWorld;
import vf.interfaces   : ISensAble, IEnterAble;
import vf.auto_methods : auto_methods;
import vf.la        : La, LaType;


class World : BaseWorld!(La,LaType,WX)
{
    alias WX = WX;

    override
    void sense( La* la, LaType la_type )
    //      this       la             la_type
    //      RDI        RSI               RDX
    {
        super.sense( la, la_type );
        TranslateMessage( &la.msg );
        DispatchMessage( &la.msg );
    }

}
