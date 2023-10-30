module vf.platform.windows.sensor;

version(WINDOWS):
import core.sys.windows.windows;
import vf.event;


interface ISensor
{
    void sense( Event* event, EVENT_TYPE event_type );
    //      this       event             event_type         
    //      RDI        RSI               RDX
    //void* sense_result();
}
