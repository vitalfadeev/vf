module vf.input.timer.event;

import vf.input.vf.event : VF_TIMER;
import vf.input.vf.queue : VfQueue;
import core.time         : MonoTime;


struct TimerEvent
{
    Timestamp timestamp;
    EventType event_type = VF_TIMER;
    void*     data;

    alias Timestamp = MonoTime;  // MonoTime = long
    alias EventType = uint;
}

void timer_callback()
{
    VfQueue.put( 
        VfEvent( TimerEvent( 
            /*timestamp*/ MonoTime.currTime, 
            /*type*/      VF_TIMER, 
            /*data*/      null ) ) 
    );
}

// jiffies
// extern ulong jiffies;
// [link](https://www.kernel.org/doc/html/v5.0/driver-api/basics.html?highlight=timer#c.add_timer)
// void init_timer_key(struct timer_list * timer, void (*func) (struct timer_list *, unsigned int flags, const char * name, struct lock_class_key * key)
// void msleep(unsigned int msecs)
// unsigned long msleep_interruptible(unsigned int msecs)
// wait_event(wq_head, condition)
// wait_event_timeout(wq_head, condition, timeout)
// wait_event_cmd(wq_head, condition, cmd1, cmd2)
// wait_event_interruptible(wq_head, condition)
// wait_event_interruptible_timeout(wq_head, condition, timeout)
// wait_event_hrtimeout(wq_head, condition, timeout)
// struct hrtimer

// ktime_get()
// ktime_t ktime_get_real(void)

// POSIX (interval) timers:
//       Real-time library (librt, -lrt)
//       #include <signal.h>           /* Definition of SIGEV_* constants */
//       #include <time.h>
//       int timer_create(clockid_t clockid, struct sigevent *_Nullable restrict sevp,timer_t *restrict timerid);
