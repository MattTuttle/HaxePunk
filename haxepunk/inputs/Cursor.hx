package haxepunk.inputs;

class Cursor
{

    /**
     * The state of the cursor's visibility.
     */
    public static var visible(default, set):Bool = true;
    private static function set_visible(value:Bool):Bool
    {
#if lime
        if (value)
        {
            lime.ui.Mouse.show();
        }
        else
        {
            lime.ui.Mouse.hide();
        }
#end
        return visible = value;
    }

#if lime
    /**
     * The look of the mouse cursor.
     */
    public static var cursor(get, set):lime.ui.MouseCursor;
    private static inline function get_cursor():lime.ui.MouseCursor { return lime.ui.Mouse.cursor; }
    private static inline function set_cursor(value:lime.ui.MouseCursor):lime.ui.MouseCursor { return lime.ui.Mouse.cursor = value; }

    /**
     * Whether or not the mouse cursor is locked to the window.
     */
    public static var isLocked(get, set):Bool;
    private static inline function get_isLocked():Bool { return lime.ui.Mouse.lock; }
    private static inline function set_isLocked(value:Bool):Bool { return lime.ui.Mouse.lock = value; }
#end

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
