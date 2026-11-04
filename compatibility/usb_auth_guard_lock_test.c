/* Uses an empty temporary tree; no sysfs access or physical adapters. */
static char test_state[4096];
#define STATE test_state
#define main guard_cli_main
#include "usb_auth_guard.c"
#undef main
#include <assert.h>
#include <sys/wait.h>
int main(void) {
 char parent[]="/tmp/onyx-guard-lock-XXXXXX";
 assert(mkdtemp(parent));
 assert(snprintf(test_state,sizeof(test_state),"%s/state",parent)>0);
 int fd=acquire_lock(); assert(fd>=0);
 struct stat st; assert(!stat(test_state,&st) && (st.st_mode&0777)==0700);
 pid_t child=fork(); assert(child>=0);
 if(!child) { close(fd); int other=acquire_lock(); _exit(other<0?0:1); }
 int status; assert(waitpid(child,&status,0)==child && WIFEXITED(status) && !WEXITSTATUS(status));
 close(fd); fd=acquire_lock(); assert(fd>=0); close(fd);
 char lock[8192]; assert(snprintf(lock,sizeof(lock),"%s/usb-auth-guard.lock",test_state)>0);
 assert(!unlink(lock)); assert(!symlink("/dev/null",lock)); assert(acquire_lock()<0);
 assert(!unlink(lock)); assert(!rmdir(test_state));
 assert(!symlink(parent,test_state)); assert(acquire_lock()<0); assert(!unlink(test_state));
 assert(supported_adapter(0x2357,0x011f)); assert(supported_adapter(0x2357,0x0120)); assert(supported_adapter(0x2357,0x010c));
 assert(!supported_adapter(0x2357,0xffff)); assert(!supported_adapter(0xffff,0x011f));
 assert(!rmdir(parent));
 puts("PASS fresh directory, repeat acquisition, duplicate rejection, symlink refusal, exact USB IDs");
 return 0;
}
