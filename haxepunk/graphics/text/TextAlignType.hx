package haxepunk.graphics.text;

#if lime

typedef TextAlignType = openfl.text.TextFormatAlign;

#else

enum abstract TextAlignType(String) from String to String
{
	var LEFT = "left";
	var CENTER = "center";
	var RIGHT = "right";
}

#end
