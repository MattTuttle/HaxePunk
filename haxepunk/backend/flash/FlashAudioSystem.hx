package haxepunk.backend.flash;

class FlashAudioSystem implements haxepunk.audio.AudioSystem
{
	public function new()
	{

	}

	/**
	 * Retrieves a sound effect if it exists in the app assets, otherwise it returns null
	 */
	public function getSfx(name:String):Null<Sfx>
	{
		return new Sfx(name);
	}

	/**
	 * Global volume factor for all sounds, a value from 0 to 1.
	 */
	public var volume(default, set):Float;
	inline function set_volume(value:Float) return pan = value;

	/**
	 * Global panning factor for all sounds, a value from -1 to 1.
	 * Panning only applies to mono sounds. It is ignored on stereo.
	 */
	public var pan(default, set):Float;
	inline function set_pan(value:Float) return pan = value;

	/**
	 * Destroys any memory created by the audio system
	 */
	public function destroy():Void
	{

	}
}
