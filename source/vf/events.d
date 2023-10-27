// UDEV
//   foreach( event; queue )
//     foreach( sensor; sensors )
//       sensor.semse( event)

// EVDEV
//   foreach( event; queue )
//     foreach( sensor; sensors )
//       sensor.semse( event)

// D-BUS
//   foreach( event; queue )
//     foreach( sensor; sensors )
//       sensor.semse( event)

// CUSTOM GRAPHICS QUEUE
//   foreach( event; queue )
//     foreach( sensor; sensors )
//       sensor.semse( event)

// EVENT
// main_proc:
//   // args: RDI, RSI, RDX, RCX, R8, R9
//   ESI = &event
//   selector = [ESI]
//
// main_proc_exit:
//   ret
//
// e_proc:
//   arg1 = [ESI + selector.size]
//   arg2 = [ESI + selector.size + arg1.size]
//   arg3 = [ESI + selector.size + arg1.size + arg2.size]
//   ...
//   jmp main_proc_exit

// EVENT
// event
//   type    // selector
//   args...
//           // fixed size of event
//
// jmp_addr = jmp_table + event.selector * ptr_size
// jmp [jmp_addr]
// 
// jmp_table
//   &event_proc_1
//   &event_proc_2
//   &event_proc_3
// 
// event_proc_1
// event_proc_2
// event_proc_3
// 

// 3 TABLES
// event
//   type                   // 0xFFFFFFFF
//     table_selector       // 0xFFFF0000
//     proc_selector        // 0x0000FFFF
//   args...
//                          // fixed size of event
//
// tbl_addr = [jmp_tables] + event.table_selector * ptr_size
//
// jmp_addr = [tbl_addr] + event.selector * ptr_size
// jmp [jmp_addr]
//
// main_proc_exit:
//   ret
// 
// jmp_tables: 
//   &jmp_table_1
//   &jmp_table_2
//   &jmp_table_3
// 
// jmp_table_1
//   &event_proc_1_1
//   &event_proc_1_2
//   &event_proc_1_3
// 
// jmp_table_2
//   &event_proc_2_1
//   &event_proc_2_2
//   &event_proc_2_3
// 
// jmp_table_3
//   &event_proc_3_1
//   &event_proc_3_2
//   &event_proc_3_3
// 
// event_proc_1_1
// event_proc_1_2
// event_proc_1_3
// event_proc_2_1
// event_proc_2_2
// event_proc_2_3
// event_proc_3_1
// event_proc_3_2
// event_proc_3_3
//   ...
//   jmp main_proc_exit

// EVENT TYPE
// event
//   type = 0..10            // 0b00 .. 0b00001010
//   type_mask = 0b00001111  //         0b00001111  
//                           // aligned 2^^n - 1 = 0b1111 = 0xFF = 15
//                           //         n = 4
//                           //         2^^n = 16
//                           //         8 < type.max < 16
//                           //         8 < 10 < 16
// ESI = event.type
//
// jmp_i    = event.type & 0x000000FF
// jmp_addr = [tbl_addr] + jmp_i * ptr_size
//
// tbl_i    = event.type & 0xFFFF0000
// tbl_addr = [jmp_tables] + tbl_i * ptr_size

// EMPTY
// jmp_table_1
//   &event_proc_1_1
//   &main_proc_exit
//   &main_proc_exit
//   &main_proc_exit

// MASK
// event.type = 0x00_01
//   tbl_mask = 0x00
//   jmp_mask = 0x01
// 
// scan suported types : EVENT_TYPE
//   tables
//     mask
//   jmps
//     mask
//   procs
//     ...
//
// struct
//   on_...( Event* e )
//
// class
//   on_...( Event* e )
//
// module
//   on_...( Event* e )

// OPTIMIZATION
// on_... <= 2 
//   if event.type == EVENT_TYPE... { ...; goto _exit; }
//   if event.type == EVENT_TYPE... { ...; goto _exit; }
// on_... >= 3
//   jmp_table
//   
//   REDUCE TABLE SIZE
//     analaize EVENT_TYPEs
//     make slices


alias REG = size_t;

enum EVENT_TYPE
{
    _  = 0x00_00,
    T1 = 0x00_01,  // table 0, jmp 1
    T2 = 0x00_02,
    T3 = 0x00_03,
}

struct Event
{
    EVENT_TYPE type;
}

void main_proc( REG edi, Event* event )
    // REG edi = ...
    // REG esi = event
{
    enum JMP_ADDR_R   = "R8";
    enum TBL_ADDR_R   = "R9";
    enum TBL_I_R      = "R10";          // event.type.table
    enum JMP_TABLES_R = "R11";          // &jmp_tables
    enum JMP_I_R      = "R12";          // event.type.jmp
    alias PTR         = void*;
    enum PTR_SIZE     = PTR.sizeof;

    // MASK
    // table mask
    // jmp mask

    // SELECT
    mixin( format!"asm {
        lea TBL_ADDR_R, [ JMP_TABLES_R + TBL_I_R * PTR_SIZE ];
        lea JMP_ADDR_R, [ TBL_ADDR_R   + JMP_I_R * PTR_SIZE ];
        jmp [JMP_ADDR_R];
    }"( JMP_TABLES_R, TBL_ADDR_R, JMP_ADDR_R, TBL_I_R, JMP_I_R, PTR_SIZE ));

    // JMP TABLES
    struct jmp_tables_t {
        PTR tbl1 = &jmp_table_1;
        PTR tbl2 = &jmp_table_2;
        PTR tbl3 = &jmp_table_3;
    }
    static jmp_tables_t jmp_tables;

    // JMP TABLE1
    struct jmp_table_1_t {
        PTR jmp1 = &event_proc_1_1;
        PTR jmp2 = &event_proc_1_2;
        PTR jmp3 = &event_proc_1_3;
    }
    static jmp_table_1_t jmp_table_1;

    // PROC
    event_proc_1_1:
        goto main_proc_exit;

    event_proc_1_2:
        goto main_proc_exit;

    event_proc_1_2:
        goto main_proc_exit;

    // EXIT
    main_proc_exit:
        return;
}
