package haxepunk.debug;

import haxepunk.graphics.*;
import haxepunk.math.Rectangle;

/**
 * Stores a continuous list of values in a ring buffer.
 * It keeps track of a running average as well as the ability to graph its' data.
 */
class Statistic
{

    /**
     * Color of the line to draw.
     */
    public var color:Color;

    /**
     * Minimum value.
     */
    public var min:Float = 0;

    /**
     * Maximum value.
     */
    public var max:Float = 1;

    public var maxSaved(default, set):Int;
    private function set_maxSaved(value:Int):Int
    {
        maxSaved = value;
        reset();
        return maxSaved;
    }

    public var average(default, null):Float;

    public function new(maxSaved:Int=15, ?color:Color)
    {
        _values = new Array<Float>();
        this.color = (color == null) ? new Color() : color;
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

    public function draw(rect:Rectangle):Void
    {
        var x = rect.x,
            y = rect.y + rect.height, // set y to bottom
            stepX = rect.width / maxSaved,
            h = rect.height,
            total = max - min,
            index = _addedValues % maxSaved;
        var lastValue:Float = (_values[index] - min) / total;
        for (i in 1...maxSaved)
        {
            var value = (_values[++index % maxSaved] - min) / total;
            Draw.line(x, y - lastValue * h, x + stepX, y - value * h, color);
            lastValue = value;
            x += stepX;
        }
    }

    private var _addedValues:Int; /** @private number of values added overall */
    private var _sum:Float = 0;
    private var _values:Array<Float>;
}
