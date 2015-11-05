package haxepunk.inputs;

import lime.ui.Mouse;
import lime.ui.MouseCursor;

class Cursor
{

    /**
     * The state of the cursor's visibility.
     */
    public static var visible(default, set):Bool = true;
    private static function set_visible(value:Bool):Bool
    {
        if (value)
        {
            Mouse.show();
        }
        else
        {
            Mouse.hide();
        }
        return visible = value;
    }

    /**
     * The look of the mouse cursor.
     */
    public static var cursor(get, set):MouseCursor;
    private static inline function get_cursor():MouseCursor { return Mouse.cursor; }
    private static inline function set_cursor(value:MouseCursor):MouseCursor { return Mouse.cursor = value; }

    /**
     * Whether or not the mouse cursor is locked to the window.
     */
    public static var isLocked(get, set):Bool;
    private static inline function get_isLocked():Bool { return Mouse.lock; }
    private static inline function set_isLocked(value:Bool):Bool { return Mouse.lock = value; }

    /**
     * Shows the mouse cursor.
     */
    public static inline function show()
    {
        visible = true;
    }

    /**
     * Hides the mouse cursor.
     */
    public static inline function hide()
    {
        visible = false;
    }

    /**
     * Locks the mouse cursor in place.
     */
    public static inline function lock()
    {
        isLocked = true;
    }

    /**
     * Unlocks the mouse cursor from the window.
     */
    public static inline function unlock()
    {
        isLocked = true;
    }

}
