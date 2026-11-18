#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/prctl.h>
#include <signal.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static volatile sig_atomic_t stop_signal;
static void on_signal(int s) { stop_signal=s; }
static long now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC,&t); return t.tv_sec; }
static void pause_tick(void) { struct timespec t={0,100000000}; nanosleep(&t,NULL); }
int main(int argc,char **argv) {
 if(argc<4 || strcmp(argv[2],"--")) { fprintf(stderr,"usage: supervisor cleanup-script -- command [args]\n"); return 2; }
 struct sigaction sa={0}; sa.sa_handler=on_signal; sigemptyset(&sa.sa_mask);
 sigaction(SIGTERM,&sa,NULL); sigaction(SIGINT,&sa,NULL); sigaction(SIGHUP,&sa,NULL);
 pid_t parent=getpid(), child=fork();
 if(child<0) return 3;
 if(child==0) {
  setpgid(0,0);
  prctl(PR_SET_PDEATHSIG,SIGTERM);
  if(getppid()!=parent) _exit(125);
  signal(SIGTERM,SIG_DFL); signal(SIGINT,SIG_DFL); signal(SIGHUP,SIG_DFL);
  execvp(argv[3],argv+3); perror("exec child"); _exit(127);
 }
 setpgid(child,child);
 int status=0, waited=0; long started=now();
 for(;;) {
  pid_t p=waitpid(child,&status,WNOHANG);
  if(p==child) { waited=1; break; }
  if(p<0 && errno!=EINTR) break;
  if(stop_signal || now()-started>=1800) break;
  pause_tick();
 }
 if(!waited) {
  kill(-child,SIGTERM); long deadline=now()+5;
  while(now()<deadline) {
   pid_t p=waitpid(child,&status,WNOHANG);
   if(p==child) { waited=1; break; }
   pause_tick();
  }
  if(!waited) { kill(-child,SIGKILL); while(waitpid(child,&status,0)<0 && errno==EINTR) {} }
 }
 fprintf(stderr,"SUPERVISOR_CHILD_REAPED\n");
 pid_t cleaner=fork();
 if(cleaner==0) { execl("/system/bin/sh","sh",argv[1],(char*)NULL); perror("exec cleanup"); _exit(127); }
 if(cleaner<0) return 4;
 int cs=0; while(waitpid(cleaner,&cs,0)<0) { if(errno!=EINTR) return 5; }
 if(!WIFEXITED(cs) || WEXITSTATUS(cs)) return 6;
 fprintf(stderr,"SUPERVISOR_CLEANUP_PASS\n");
 return 0;
}
