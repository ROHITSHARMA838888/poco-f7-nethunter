import dbus, dbus.service, dbus.mainloop.glib
from gi.repository import GLib
import os
TARGET=os.environ['ONYX_HID_TARGET'].upper()
class Rejected(dbus.DBusException):
 _dbus_error_name='org.bluez.Error.Rejected'
class Agent(dbus.service.Object):
 def check(self,device):
  p=dbus.Interface(bus.get_object('org.bluez',device),'org.freedesktop.DBus.Properties')
  if str(p.Get('org.bluez.Device1','Address')).upper()!=TARGET: raise Rejected('Only owned laptop allowed')
 @dbus.service.method('org.bluez.Agent1',in_signature='',out_signature='')
 def Release(self): pass
 @dbus.service.method('org.bluez.Agent1',in_signature='o',out_signature='s')
 def RequestPinCode(self,device): self.check(device); print('PIN_REQUEST',flush=True); return '482915'
 @dbus.service.method('org.bluez.Agent1',in_signature='o',out_signature='u')
 def RequestPasskey(self,device): self.check(device); print('PASSKEY_REQUEST',flush=True); return dbus.UInt32(482915)
 @dbus.service.method('org.bluez.Agent1',in_signature='ou',out_signature='')
 def RequestConfirmation(self,device,passkey): self.check(device); print('OWNED_LAPTOP_CONFIRMATION',int(passkey),flush=True)
 @dbus.service.method('org.bluez.Agent1',in_signature='o',out_signature='')
 def RequestAuthorization(self,device): self.check(device); print('OWNED_LAPTOP_AUTHORIZED',flush=True)
 @dbus.service.method('org.bluez.Agent1',in_signature='os',out_signature='')
 def AuthorizeService(self,device,uuid):
  self.check(device)
  if str(uuid).lower()!='00001124-0000-1000-8000-00805f9b34fb': raise Rejected('HID service only')
 @dbus.service.method('org.bluez.Agent1',in_signature='ouq',out_signature='')
 def DisplayPasskey(self,device,passkey,entered): self.check(device); print('DISPLAY_PASSKEY',int(passkey),flush=True)
 @dbus.service.method('org.bluez.Agent1',in_signature='',out_signature='')
 def Cancel(self): print('PAIRING_CANCELLED',flush=True)
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus=dbus.SystemBus(); agent=Agent(bus,'/onyx/hid_agent')
mgr=dbus.Interface(bus.get_object('org.bluez','/org/bluez'),'org.bluez.AgentManager1')
mgr.RegisterAgent('/onyx/hid_agent','NoInputNoOutput');mgr.RequestDefaultAgent('/onyx/hid_agent')
print('PAIRING_AGENT_READY_OWNED_LAPTOP_ONLY',flush=True)
GLib.MainLoop().run()
