import os,subprocess,time,signal,sys
os.chdir('/root/onyx-bluetooth-module/hid')
os.environ['PATH']='/usr/sbin:/usr/bin:/sbin:/bin'
os.environ['DBUS_SYSTEM_BUS_ADDRESS']='unix:path='+os.getcwd()+'/bus.sock'
children=[]
def stop(s,f): raise SystemExit(0)
signal.signal(signal.SIGTERM,stop);signal.signal(signal.SIGINT,stop);signal.signal(signal.SIGHUP,stop)
def launch(args,name):
 p=subprocess.Popen(args,stdout=open(name+'.log','w'),stderr=subprocess.STDOUT);children.append(p);return p
try:
 if os.path.exists('bus.sock'): raise RuntimeError('Old bus socket: inspect previous cleanup')
 bus=launch(['dbus-daemon','--nofork','--config-file=bus.conf'],'bus');time.sleep(1)
 bluez=launch(['/usr/libexec/bluetooth/bluetoothd','-n','--noplugin=input'],'bluez');time.sleep(2)
 agent=launch(['python3','-u','pair-agent.py'],'agent');time.sleep(1)
 keyboard=launch(['python3','-u','btk_server.py','-n','Onyx HID Test','-i','hci0'],'keyboard');time.sleep(3)
 if any(p.poll() is not None for p in children): raise RuntimeError('HID component exited; inspect logs')
 print('HID_READY_NO_AUTOMATIC_KEYS',flush=True)
 while all(p.poll() is None for p in children): time.sleep(1)
finally:
 for p in reversed(children):
  if p.poll() is None: p.terminate()
 for p in children:
  try:p.wait(timeout=3)
  except subprocess.TimeoutExpired:p.kill();p.wait()
 if os.path.exists('bus.sock'):os.unlink('bus.sock')
