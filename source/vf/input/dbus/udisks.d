module vf.input.dbus.udisks;

// /org/freedesktop/UDisks2

alias s = string;

// UDisks2
struct UDisks2
{
    //
}

// UDisks2.Manager
//struct Manager
//{
//    s  Version;
//    as SupportedFilesystems;
//    as SupportedEncryptionTypes;
//    s  DefaultEncryptionType;

//    void CanFormat       (in  s     type,
//                          out (bs)  available);
//    void CanResize       (in  s     type,
//                          out (bts) available);
//    void CanCheck        (in  s     type,
//                          out (bs)  available);
//    void CanRepair       (in  s     type,
//                          out (bs)  available);
//    void LoopSetup       (in  h     fd,
//                          in  a{sv} options,
//                          out o     resulting_device);
//    void MDRaidCreate    (in  ao    blocks,
//                          in  s     level,
//                          in  s     name,
//                          in  t     chunk,
//                          in  a{sv} options,
//                          out o     resulting_array);
//    void EnableModules   (in  b     enable);
//    void EnableModule    (in  s     name,
//                          in  b     enable);
//    void GetBlockDevices (in  a{sv} options,
//                          out ao    block_objects);
//    void ResolveDevice   (in  a{sv} devspec,
//                          in  a{sv} options,
//                          out ao    devices);
//}
