import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;

/** One-shot owner-user wallpaper setup; never edits framework wallpaper files. */
public final class OnyxWallpaper {
    public static void main(String[] args) {
        try {
            if (args.length != 2 || !(args[0].equals("--check") || args[0].equals("--apply")))
                throw new IllegalArgumentException("Use --check|--apply wallpaper.png");
            Class<?> process = Class.forName("android.os.Process");
            if (((Integer)process.getMethod("myUid").invoke(null)) != 0)
                throw new SecurityException("Start this helper as root");
            Class<?> looper = Class.forName("android.os.Looper");
            // Open while root: /data/adb is deliberately private to root.
            InputStream image = args[0].equals("--apply") ? new FileInputStream(args[1]) : null;
            looper.getMethod("prepareMainLooper").invoke(null);
            Class<?> activityThread = Class.forName("android.app.ActivityThread");
            Object thread = activityThread.getMethod("systemMain").invoke(null);
            Object context = activityThread.getMethod("getSystemContext").invoke(thread);
            // The system context is attributed to package android / UID 1000.
            // Drop root before its Binder call, so package and caller UID match.
            process.getMethod("setUid", int.class).invoke(null, 1000);
            Class<?> wm = Class.forName("android.app.WallpaperManager");
            Object manager = wm.getMethod("getInstance", Class.forName("android.content.Context")).invoke(null, context);
            boolean supported = (Boolean)wm.getMethod("isWallpaperSupported").invoke(manager);
            boolean allowed = (Boolean)wm.getMethod("isSetWallpaperAllowed").invoke(manager);
            if (!supported || !allowed) throw new SecurityException("Wallpaper changes are unavailable");
            if (args[0].equals("--apply")) {
                try (InputStream opened = image) {
                    // FLAG_SYSTEM = 1: home screen only; preserve a separate lock wallpaper.
                    wm.getMethod("setStream", InputStream.class, Class.forName("android.graphics.Rect"), boolean.class, int.class)
                      .invoke(manager, opened, null, true, 1);
                }
                System.out.println("WALLPAPER_APPLIED_OWNER_HOME");
            } else {
                System.out.println("WALLPAPER_API_CHECK_PASS; no wallpaper changed");
            }
            System.exit(0);
        } catch (Throwable error) {
            if (error instanceof InvocationTargetException && error.getCause() != null) error = error.getCause();
            error.printStackTrace();
            System.exit(1);
        }
    }
}
