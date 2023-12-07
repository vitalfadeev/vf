module vf.base.sensors;

import vf.base.types : Sensor;


struct Sensors(La,LaType)
{
    Sensor!(La,LaType)[] _sensors;
    alias _sensors this;

    void sense( La* la, LaType la_type )
    //    this         la            la_type
    //    RDI          RSI              RDX
    {
        foreach( sensor; _sensors )
            sensor( la, la_type );
    }
}
