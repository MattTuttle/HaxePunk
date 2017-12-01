package haxepunk.backend.flash;

#if (lime || nme)

import flash.events.MouseEvent;
import haxepunk.input.Mouse;

@:access(haxepunk.input.Mouse)
class MouseInput
{
	@:access(haxepunk.input.Mouse)
	public static function init(app:FlashApiApp)
	{
		var stage = app.stage;
		stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			Mouse.onMouseDown();
		}, false,  2);
		stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent) {
			Mouse.onMouseUp();
		}, false,  2);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent) {
			Mouse.onMouseWheel(e.delta);
		}, false,  2);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, function(e:MouseEvent) {
			Mouse.onMiddleMouseDown();
		}, false, 2);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, function(e:MouseEvent) {
			Mouse.onMiddleMouseUp();
		}, false, 2);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, function(e:MouseEvent) {
			Mouse.onRightMouseDown();
		}, false, 2);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, function(e:MouseEvent) {
			Mouse.onRightMouseUp();
		}, false, 2);
	}
}

#end
