package haxepunk.pixel;

import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.shader.SceneShader;

class PixelArtScaler extends Entity
{
	public static var baseWidth:Null<Int> = null;
	public static var baseHeight:Null<Int> = null;

	static var s1:SceneShader;
	static var s2:SceneShader;

	public static function globalActivate()
	{
		Graphic.smoothDefault = false;
		Graphic.pixelSnappingDefault = true;
		HXP.engine.onSceneSwitch.bind(activate);
	}

	public static function activate()
	{
		var e = new PixelArtScaler();
		HXP.scene.add(e);
		HXP.scene.camera.pixelSnapping = true;
		return e;
	}

	function new()
	{
		super();
		Log.debug("PixelArtScaler is no longer implemented");
		visible = collidable = false;
	}

	#if 0
	// TODO: fix and enable
	override public function update()
	{
		if (HXP.screen.width <= s1.width || HXP.screen.height <= s1.height)
		{
			s1.active = s2.active = false;
		}
		else if (HXP.screen.width == s1.width && HXP.screen.height == s1.height)
		{
			s1.active = s2.active = false;
		}
		else if (HXP.screen.width % s1.width == 0 && HXP.screen.height % s1.height == 0)
		{
			s1.active = true;
			s2.active = false;
		}
		else s1.active = s2.active = true;

		if (s2.active)
		{
			var sx = Std.int(Math.max(HXP.screen.width / s1.width, 1)),
				sy = Std.int(Math.max(HXP.screen.height / s1.height, 1));
			s2.width = Std.int(sx * s1.width);
			s2.height = Std.int(sy * s1.height);
		}
	}

	override public function added()
	{
		if (scene.shaders == null) scene.shaders = new Array();
		if (s1 == null) s1 = new SceneShader();
		s1.width = baseWidth == null ? HXP.width : baseWidth;
		s1.height = baseHeight == null ? HXP.height : baseHeight;
		s1.smooth = false;
		if (s2 == null) s2 = new SceneShader();
		resized();

		if (scene.shaders.indexOf(s1) == -1) scene.shaders.push(s1);
		if (scene.shaders.indexOf(s2) == -1) scene.shaders.push(s2);
		Log.info("pixel art shaders activated");
	}
	#end

	override public function removed()
	{
		scene.may((s) -> {
			if (s.shaders != null)
			{
				s.shaders.remove(s2);
				s.shaders.remove(s1);
			}
		});
	}
}
