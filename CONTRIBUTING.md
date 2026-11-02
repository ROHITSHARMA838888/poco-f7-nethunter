# Contributing

Use a feature branch and open a pull request against main. Describe the problem, scope, source pins, configuration/ABI impact, checks and runtime limits. Never represent a compilation success as runtime qualification. New contributors' Actions require maintainer approval.

Keep third-party Actions pinned to approved full commit SHAs. Checkout must not persist credentials. Do not add pull_request_target, secrets to untrusted PR jobs, broad token write permissions or automatic flashing/release publication. Build jobs should run only when intentionally requested. Old Konoha build workflows are disabled; current ROM-source workflows can be dispatched manually from updated main. Historical branches must be updated before they can use the repository's pinned Action allowlist.

Retain upstream licence notices, authorship and exact source provenance. No private phone logs, boot backups, tokens, SSIDs/BSSIDs/MAC/IP addresses or personal screenshots in commits. Redact diagnostics before public posting. Releases and phone writes need the maintainer's explicit approval.

Single-maintainer review: normal contributors need an approving review. Repository administrators may bypass review requirements only through an existing PR, so the sole owner can merge their own reviewed changes without enabling direct pushes. Force-push/deletion safeguards have no bypass list.
