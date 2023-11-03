module vf.platforms.windows.platform;

version(WINDOWS):
import core.sys.windows.windows;


struct Platform
{
    @disable 
    this();

    void do_init()
    {
        //
    }
}
