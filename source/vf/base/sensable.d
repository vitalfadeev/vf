module vf.base.sensable;


class SensAble(TLa,TLaType)
{
    alias THIS      = typeof(this);
    alias Sensable  = typeof(this);
    alias La     = TLa;
    alias LaType = TLaType;

    void sense( La* la, LaType la_type )
    //    this         la            la_type   src   ...  ...
    //    RDI          RSI              RDX          RCX   R8   R9
    {
        //
    }
}
