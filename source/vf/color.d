module vf.color;

version(WINDOWS_NATIVE):
import core.sys.windows.windows;
import vf.types;

struct Color32
{
    this( M8 r, M8 g, M8 b, M8 a )
    {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    union 
    {
        M32    m32;
        M8[4]  m8; 
        struct
        {
            // The Intel x86 CPUs are little endian meaning 
            // that the value 
            // 0x0A_0B_0C_0D 
            // is stored in memory as
            // 0D 0C 0B 0A.
            M8 a;
            M8 b;
            M8 g;
            M8 r;
        }
        RGBQUAD rgbquad;
    }

    enum RMASK = 0x000000FF;
    enum GMASK = 0x0000FF00;
    enum BMASK = 0x00FF0000;
    enum AMASK = 0xFF000000;
}
alias Color = Color32;
