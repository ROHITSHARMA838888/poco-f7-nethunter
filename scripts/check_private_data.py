"""Conservative credential/raw-device-data scan. Does not print matching values."""
from pathlib import Path
import argparse,json,re,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
RULES={
 'github_token':re.compile(rb'(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})'),
 'private_key':re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'),
 'aws_access_key':re.compile(rb'\bAKIA[0-9A-Z]{16}\b'),
 'google_api_key':re.compile(rb'\bAIza[0-9A-Za-z_-]{35}\b'),
}
RAW=re.compile(r'(^|/)(?:pstore|private|owned-probe-evidence-private)(/|$)|(?:boot|usb-log|dmesg|tombstone|pmsg)[^/]*\.(?:log|img|tar)$',re.I)
def inspect(data,label):
 return [{'path':label,'rule':name} for name,pattern in RULES.items() if pattern.search(data)]
def run(history=False):
 findings=[];count=0;skipped=0
 paths=subprocess.check_output(['git','ls-files','-z','--cached','--others','--exclude-standard'],cwd=ROOT).split(b'\0')
 for raw in sorted(set(paths)):
  if not raw:continue
  name=raw.decode('utf-8');p=ROOT/name
  if not p.is_file():continue
  if RAW.search(name):findings.append({'path':name,'rule':'raw_private_device_material'})
  if p.stat().st_size>4*1024*1024:skipped+=1;continue
  findings.extend(inspect(p.read_bytes(),name));count+=1
 if history:
  objects=subprocess.check_output(['git','rev-list','--objects','--all'],cwd=ROOT).splitlines()
  proc=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
  for item in objects:
   oid,_,path=item.partition(b' ')
   if not path:continue
   proc.stdin.write(oid+b'\n');proc.stdin.flush()
   head=proc.stdout.readline().split()
   if len(head)!=3:continue
   size=int(head[2]);data=proc.stdout.read(size);proc.stdout.read(1)
   if head[1]!=b'blob':continue
   if size>4*1024*1024:skipped+=1;continue
   findings.extend(inspect(data,'history:'+oid.decode()[:12]+':'+path.decode('utf-8',errors='replace')));count+=1
  proc.stdin.close();proc.wait()
 print(json.dumps({'scanned':count,'skipped_large':skipped,'findings':findings,'scope':'reachable local Git history + tracked/unignored files' if history else 'tracked/unignored files'},indent=2))
 return bool(findings)
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--history',action='store_true')
 sys.exit(run(parser.parse_args().history))
