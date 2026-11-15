# Experimental Infinity-X WCN7750 compile check

Not a release or a flashable package. No installer, firmware change or automatic deployment.
The existing working kernel Image is unchanged. Compilation and import CRC checks do not
prove firmware transmission, runtime CFI compatibility, Wi-Fi stability or deauthentication.

Source: xiaomi-onyx-playground/android_kernel_xiaomi_sm8735-modules at
02727998cd386983341bfc79c34dd20f5be7fb1b.
Monitor/injection patch: Loukious/vendor_qcom_opensource_wlan at
25875eb1a65e94fae404c6e9188c7a1fe679e0f5, adapted for four source contexts.
Build arguments adapted from Loukious/konoha-kernel-gki tools/build_wlan_injection_module.sh
at b3d87c1ee5022cb5a83109d653e3c71d3f7236e0.
Original copyright/license notices remain in upstream source and patch context.

Additional symbol CRC inputs come from Infinity-X 4.2 stock module imports and their
CRC-matched vendor providers. Kernel CRCs come from the previously tested owner build.
Extra symbol export type/namespace metadata needs source review before any production
packaging. Modpost errors must not be suppressed, and module loading must never be forced.
Any newly required imports must pass the same recorded-CRC check.
