# Exact source and build provenance — v0.1.2

Current base is NOT Konoha. Original authorship and licences remain applicable.

| Component | Upstream repository | Exact revision |
|---|---|---|
| Kernel | https://github.com/xiaomi-onyx-playground/android_kernel_xiaomi_sm8735 |7750565ada3d57e195798519b005d2b038e888c1|
| KernelSU Next |https://github.com/KernelSU-Next/KernelSU-Next|b427a3f9c2421a443f961007bfce66b25486643f|
| Archer rtl8812au |https://github.com/aircrack-ng/rtl8812au|734485506a30d6237c2deaad666a19f8ca5379f2|
| WN rtl8188eus |https://github.com/aircrack-ng/rtl8188eus|af3bf004458f76b7aec33e9ba552cd382ed1f5c3|
| AnyKernel3 |https://github.com/osm0sis/AnyKernel3|41f04bdb4ee30a44e429c2c1131d5e8bb32b15f1|
| Magisk installer tools |https://github.com/topjohnwu/Magisk|v31.1; exact tool provenance bundled with kernel|
| Kali artwork |https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-installer|aa1dca61435cc8a7e9f4053234c731855329e69b|

Full upstream source is available at each exact pinned revision. This repository includes downstream modifications, matching configuration and build/install source. `release-source/v0.1.2` contains complete kernel/driver patch files, exact resolved.config, installed installer/module shell sources, wallpaper Java helper source and packaging recipes. The recipes document the original local staging layout; they are not a claim of a one-command self-contained rebuild.

Kernel build recipe: `.github/workflows/rom-branded-kernel.yml`, LLVM22.1.8, KBUILD_BUILD_USER=Rohit-Sharma and KBUILD_BUILD_HOST=Built-for-NetHunter-Rebuilt-from-Onyx. Kernel build41207879867. Apply the kernel integration patch with KernelSU source at `.root_modules/KernelSU-Next` and `drivers/kernelsu` symlink, use matching resolved.config, then `make O=out ARCH=arm64 LLVM=-22 Image modules`. Preserve version/config/CFI/KASAN; no CRC/security bypass.

Driver recipes: `.github/workflows/rom-archer-tx-tasklet-fix.yml` (run41297489306), `.github/workflows/rom-wn722n-cfi-fix.yml` (run41316130882). Apply either the full corresponding patch OR the base/preparation helpers, not both. Use exact running kernel headers/config/Module.symvers; the matched table is available in the named public build-evidence artifacts. Archer built with CONFIG_RTW_DEBUG=y and is loaded with rtw_drv_log_level=1. WN includes software LED code. Guard source is `compatibility/usb_auth_guard.c`; its workflow is `.github/workflows/usb-auth-guard.yml` (run41200495879).

Source-Reconstruction-Kit contains these downstream sources/config/patches and recipes; it does not contain full upstream trees, toolchain binaries, user data or boot backups. Retrieve upstream trees from the exact pins above. Keep original licence notices and provide corresponding sources/modifications when redistributing, rather than removing credits.
