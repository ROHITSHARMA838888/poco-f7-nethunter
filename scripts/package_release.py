"""Assemble v0.2.0 from public text sources and hash-locked binary inputs.

This is packaging, not a substitute for compiling kernel/drivers from source.
No downloaded scripts are executed. See docs/BUILDING.md.
"""
from pathlib import Path, PurePosixPath
import argparse, hashlib, json, urllib.request, zipfile

ROOT=Path(__file__).resolve().parents[1]
FIX=ROOT/'release-source/v0.2.0/packaging'

def digest(data): return hashlib.sha256(data).hexdigest()
def safe_name(name):
 p=PurePosixPath(name)
 if p.is_absolute() or '..' in p.parts or '\\' in name or ':' in name:
  raise ValueError('Unsafe archive path')
 return p

def build(args):
 lock=json.loads((FIX/'package-inputs.lock.json').read_text())
 args.output.mkdir(parents=True,exist_ok=True)
 results=[]
 for package in lock['packages']:
  donor=None
  if args.release_directory:
   source=args.release_directory/package['asset']
   if digest(source.read_bytes())!=package['sha256']:raise ValueError('Release donor checksum mismatch')
   donor=zipfile.ZipFile(source)
  elif args.download_inputs:
   source=args.output/(package['asset']+'.input')
   if not source.exists():
    with urllib.request.urlopen(package['url'],timeout=120) as response:
     with source.open('wb') as target:
      while chunk:=response.read(1024*1024):target.write(chunk)
   if digest(source.read_bytes())!=package['sha256']:raise ValueError('Downloaded donor checksum mismatch')
   donor=zipfile.ZipFile(source)
  data={}
  for entry in package['entries']:
   path=safe_name(entry['name'])
   override=args.inputs/package['kind']/path if args.inputs else None
   if override and override.is_file():body=override.read_bytes()
   elif entry['template']:body=(FIX/entry['template']).read_bytes()
   elif donor:body=donor.read(entry['name'])
   else:raise ValueError('Missing binary input: '+package['kind']+'/'+entry['name'])
   if not args.development and digest(body)!=entry['sha256']:
    raise ValueError('Input content differs from release: '+entry['name'])
   data[entry['name']]=body
  if args.development:
   # Rehash from the innermost manifest out. Never reuse stale integrity files.
   manifests=sorted((n for n in data if n.endswith(('SHA256SUMS','SHA256SUMS.txt'))),key=lambda n:n.count('/'),reverse=True)
   if package['kind']=='module':
    manifests=[n for n in manifests if n not in ('GUARD_SHA256SUMS','PACKAGE_SHA256SUMS')]+['GUARD_SHA256SUMS','PACKAGE_SHA256SUMS']
   for name in manifests:
    if name not in data:continue
    prefix=name.rpartition('/')[0]
    lines=[]
    for line in data[name].decode().splitlines():
     if not line.strip():continue
     _,rel=line.split('  ',1)
     full=str(PurePosixPath(prefix)/safe_name(rel))
     # This manifest is installed alongside driver copies in /data/adb,
     # while those binaries live in drivers/ inside the module ZIP.
     if package['kind']=='module' and name=='payload/SHA256SUMS' and rel in ('88XXau.ko','8188eu.ko'):
      full='drivers/'+rel
     if full not in data:raise ValueError('Manifest input absent: '+full)
     lines.append(digest(data[full])+'  '+rel)
    data[name]=('\n'.join(lines)+'\n').encode()
  output=args.output/package['asset']
  if output.exists():raise FileExistsError(output)
  with zipfile.ZipFile(output,'w') as z:
   for entry in package['entries']:
    info=zipfile.ZipInfo(entry['name'],tuple(entry['date_time']))
    for attr in ('compress_type','external_attr','create_system','flag_bits'):setattr(info,attr,entry[attr])
    info.extra=bytes.fromhex(entry['extra']);info.comment=bytes.fromhex(entry['comment'])
    z.writestr(info,data[entry['name']])
  if donor:donor.close()
  with zipfile.ZipFile(output) as z:
   if z.testzip():raise ValueError('Corrupt archive')
  results.append({'file':output.name,'sha256':digest(output.read_bytes()),'content_matches_release':not args.development})
 (args.output/'SHA256SUMS.txt').write_text(''.join(x['sha256']+'  '+x['file']+'\n' for x in results))
 print(json.dumps(results,indent=2))

if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--output',type=Path,required=True)
 parser.add_argument('--inputs',type=Path,help='Compiled/data inputs: kernel/<zip-path> and module/<zip-path>')
 group=parser.add_mutually_exclusive_group()
 group.add_argument('--release-directory',type=Path,help='Use verified released ZIPs only for binary/data inputs')
 group.add_argument('--download-inputs',action='store_true',help='Download hash-locked original assets, ~94 MB')
 parser.add_argument('--development',action='store_true',help='Allow changed source/compiled inputs and regenerate manifests; outputs require testing')
 build(parser.parse_args())
