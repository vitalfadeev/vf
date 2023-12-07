module vf.input.app.timer.la;

// jiffies
// extern ulong jiffies;
// [link](https://www.kernel.org/doc/html/v5.0/driver-api/basics.html?highlight=timer#c.add_timer)
// void init_timer_key(struct timer_list * timer, void (*func) (struct timer_list *, unsigned int flags, const char * name, struct lock_class_key * key)
// void msleep(unsigned int msecs)
// unsigned long msleep_interruptible(unsigned int msecs)
// wait_la(wq_head, condition)
// wait_la_timeout(wq_head, condition, timeout)
// wait_la_cmd(wq_head, condition, cmd1, cmd2)
// wait_la_interruptible(wq_head, condition)
// wait_la_interruptible_timeout(wq_head, condition, timeout)
// wait_la_hrtimeout(wq_head, condition, timeout)
// struct hrtimer

// ktime_get()
// ktime_t ktime_get_real(void)

// POSIX (interval) timers:
//       Real-time library (librt, -lrt)
//       #include <signal.h>           /* Definition of SIGEV_* constants */
//       #include <time.h>
//       int timer_create(clockid_t clockid, struct sigla *_Nullable restrict sevp,timer_t *restrict timerid);

