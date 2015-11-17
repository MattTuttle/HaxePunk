package haxepunk.inputs;

class Touch
{
    public var device:Int;
	public var dx:Float;
	public var dy:Float;
	public var id:Int;
	public var pressure:Float;
	public var x:Float;
	public var y:Float;

	public function new (id:Int)
	{
		this.id = id;
	}
}
