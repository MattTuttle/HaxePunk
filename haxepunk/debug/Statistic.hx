package haxepunk.debug;

/**
 * Stores a continuous list of values in a ring buffer.
 * It keeps track of a running average as well as the ability to graph its' data.
 */
class Statistic
{

    public var maxSaved(default, set):Int;
    private function set_maxSaved(value:Int):Int
    {
        maxSaved = value;
        reset();
        return maxSaved;
    }

    public var average(default, null):Float;

    public function new(maxSaved:Int=15)
    {
        _values = new Array<Float>();
        this.maxSaved = maxSaved;
    }

    public function toString():String
    {
        return 'Statistic<$average>';
    }

    public function add(value:Float):Void
    {
        var index = _addedValues % maxSaved,
            totalSavedValues = (_addedValues < maxSaved) ? _addedValues : maxSaved;
        _sum += value - _values[index]; // add newest and remove oldest value
        _values[index] = value;
        average = _sum / totalSavedValues;
        _addedValues += 1;
    }

    public function reset():Void
    {
        for (i in 0...maxSaved)
        {
            _values[i] = 0;
        }
        average = _sum = _addedValues = 0;
    }

    public function draw():Void
    {
        // Draw.line();
    }

    private var _addedValues:Int; /** @private number of values added overall */
    private var _sum:Float = 0;
    private var _values:Array<Float>;
}
