package haxepunk.graphics.text;

#if (lime || nme)

typedef Text = haxepunk.backend.flash.Text;

#else

class Text extends Graphic
{
	public var resizable:Bool;
	public var text:String;
	public var size:Int;
	public var richText:String;

	public function new(?_, ?_, ?_, ?_, ?_, ?_)
	{
		super();
	}

	public function addStyle(text:String, options:Dynamic) {}
	public function centerOrigin() {}
}

#end
