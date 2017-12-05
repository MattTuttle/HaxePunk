package haxepunk.audio;

interface AudioSystem
{
	/**
	 * Retrieves a sound effect if it exists in the app assets, otherwise it returns null
	 */
	public function getSfx(name:String):Null<Sfx>;

	/**
	 * Global volume factor for all sounds, a value from 0 to 1.
	 */
	public var volume(default, set):Float;

	/**
	 * Global panning factor for all sounds, a value from -1 to 1.
	 * Panning only applies to mono sounds. It is ignored on stereo.
	 */
	public var pan(default, set):Float;

	/**
	 * Destroys any memory created by the audio system
	 */
	public function destroy():Void;

}
