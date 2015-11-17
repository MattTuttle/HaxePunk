package haxepunk;

@:enum abstract LogLevel(Int) to Int
{
    var Error = 5;
    var Warning = 4;
    var Info = 3;
    var Verbose = 0;

    public inline function toString():String
    {
        return switch (this) {
            case Info: "INFO";
            case Warning: "WARN";
            case Error: "ERR";
            default: "---";
        };
    }
}

typedef Message = {
    message:String,
    level:LogLevel
};

class Log
{

    public static var output:Bool = true;

    public static function log(message:String, level:LogLevel=Verbose):Void
    {
        _messages.push({
            message: message,
            level: level
        });
        if (output)
        {
#if (flash || html5)
            trace(level.toString() + ": " + message);
#else
            Sys.println(level.toString() + ": " + message);
#end
        }
    }

    public static inline function info(message:String):Void { log(message, Info); }
    public static inline function warn(message:String):Void { log(message, Warning); }
    public static inline function error(message:String):Void { log(message, Error); }

    private static var _messages = new Array<Message>();

}
