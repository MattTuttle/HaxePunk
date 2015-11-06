package haxepunk;

import lime.ui.Window;
import haxepunk.scene.Scene;
import haxepunk.graphics.SpriteBatch;
import haxepunk.graphics.Color;

enum ScaleMode
{
	NoScale;
	Stretch;
	Zoom;
	LetterBox;
}

@:allow(haxepunk.Engine)
class HXP
{
	public static var window:Window;

	public static var scaleMode:ScaleMode = LetterBox;

	// TODO: change this so it can't get out of sync with Engine
	public static var scene(default, null):Scene;

	@:allow(haxepunk.scene.Scene)
	public static var frameRate(default, null):Float = 0;

	public static var entityColor:Color = new Color(1, 0, 0, 0.3);
	public static var maskColor:Color = new Color(0, 1, 0, 0.3);
	public static var selectColor:Color = new Color(0.9, 0.9, 0.9);
}
