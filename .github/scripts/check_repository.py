"""Lightweight public-PR validation; never build or execute supplied source."""
from pathlib import Path
import ast
import re

for path in Path('.').rglob('*.py'):
    if '.git' not in path.parts:
        ast.parse(path.read_text(encoding='utf-8-sig'), filename=str(path))
for path in Path('.github/workflows').glob('*.yml'):
    text = path.read_text(encoding='utf-8')
    assert not re.search(r'^\s*pull_request_target\s*:', text, re.M), path
    for action in re.findall(r'uses:\s*([^\s#]+)', text):
        assert re.fullmatch(r'actions/(checkout|upload-artifact|download-artifact|cache/restore|cache/save)@[0-9a-f]{40}', action), (path, action)
    assert 'contents: write' not in text and 'write-all' not in text, path
print('Python syntax and workflow action/security checks passed')

# Only inspect bytes; do not import/execute PR-provided Python modules.
private_patterns = [
    rb'gh[pousr]_[A-Za-z0-9]{30,}',
    rb'github_pat_[A-Za-z0-9_]{40,}',
    rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----',
]
for path in Path('.').rglob('*'):
    if not path.is_file() or any(part in ('.git', '.private', '__pycache__') for part in path.parts):
        continue
    if path.stat().st_size > 4 * 1024 * 1024:
        continue
    body = path.read_bytes()
    for pattern in private_patterns:
        assert not re.search(pattern, body), f'Potential credential in {path}; inspect privately'
print('Recognized credential-pattern scan passed (not a complete secret audit)')
