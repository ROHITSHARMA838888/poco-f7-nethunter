# Public source and private data

This project intentionally stays open source: source, patches, build scripts, configs, dependency pins and sanitized test results remain public so others can continue development. Public code cannot be made immune to reuse or misuse by hiding the README.

Do not commit tokens, private keys, account sessions, Wi-Fi passwords, personal serial/MAC/IP/SSID details, raw phone/crash logs, boot backups or complete private chat exports. Use a separate private location or `.private/` for local evidence. `.gitignore` only reduces accidental tracking; it is not access control or encryption.

The privacy scanner checks recognized credential formats and known categories of raw device files. It prints only paths/rule names, never matching values. Its Git-history mode scans reachable objects in the local clone. It cannot prove that no secret exists in arbitrary formats, deleted branches, forks, GitHub caches, issues or remote artifacts.

```sh
python3 scripts/check_private_data.py
python3 scripts/check_private_data.py --history
```

If a real credential was already public: revoke/rotate it first, preserve the finding privately and notify the owner. Removing the current file does not remove history. History rewriting, deleting releases/artifacts or changing repo visibility requires explicit owner authorization and coordination with other clones. Never print the credential or promise that hiding a file makes it secret again.

Copyright names, public maintainer usernames, source URLs, ABI tables and default Android paths are normally public provenance, not credentials. Do not erase required notices. Never upload a secret as a GitHub Actions artifact.
