package haxepunk.backend.flash;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import haxepunk.assets.AssetLoader;
import haxepunk.math.MathUtil;

/**
 * Sound effect object used to play embedded sounds.
 */
class Sfx
{
	/**
	 * Optional callback function for when the sound finishes playing.
	 */
	@:dox(hide) // mistaken for a class function
	public var complete:Void -> Void;

	/**
	 * Creates a sound effect from an embedded source. Store a reference to
	 * this object so that you can play the sound using play() or loop().
	 * @param	source		The embedded sound class to use.
	 * @param	complete	Optional callback function for when the sound finishes playing.
	 */
	public function new(source:Dynamic, ?complete:Void -> Void)
	{
		_transform = new SoundTransform();
		_volume = 1;
		_pan = 0;
		_position = 0;
		_type = "";

		if (source == null)
			throw "Invalid source Sound.";

		if (Std.is(source, String))
		{
			_sound = AssetCache.global.getSound(source);
			_sounds.set(source, _sound);
		}
		else
		{
			var className:String = Type.getClassName(Type.getClass(source));

			if (StringTools.endsWith(className, "media.Sound"))
			{
				// used for loading sound runtime (data-driven for test and debug)
				var __sound:Sound = cast source;
				_sound = _sounds.get(__sound.url);
				if ( _sound == null )
				{
					_sound = source;
					_sounds.set(__sound.url, source);
				}
			}
			else
			{
				_sound = _sounds.get(className);
				if (_sound == null)
				{
					_sound = source;
					_sounds.set(className, source);
				}
			}
		}

		this.complete = complete;
	}

	/** @private Event handler for sound completion. */
	function onComplete(?e:Event)
	{
		if (_looping) loop(_volume, _pan);
		else stop();

		_position = 0;
		if (complete != null) complete();
	}

	/** @private Add the sound to a list of those currently playing. */
	function addPlaying()
	{
		var list:Array<Sfx>;
		if (!_typePlaying.exists(_type))
		{
			list = new Array<Sfx>();
			_typePlaying.set(_type, list);
		}
		else
		{
			list = _typePlaying.get(_type);
		}
		list.push(this);
	}

	/** @private Removes the sound from the list of those currently playing. */
	function removePlaying()
	{
		if (_typePlaying.exists(_type))
		{
			_typePlaying.get(_type).remove(this);
		}
	}

	/**
	 * Alter the panning factor (a value from -1 to 1) of the sound during playback.
	 * Panning only applies to mono sounds. It is ignored on stereo.
	 */
	public var pan(get, set):Float;
	function get_pan():Float return _pan;
	function set_pan(value:Float):Float
	{
		value = MathUtil.clamp(value, -1, 1);
		if (_channel == null) return value;
		var filteredPan:Float = MathUtil.clamp(value + getPan(_type), -1, 1);
		if (_filteredPan == filteredPan) return value;
		_pan = value;
		_filteredPan = _transform.pan = filteredPan;
		_channel.soundTransform = _transform;
		return _pan;
	}

	/**
	 * Change the sound type. This an arbitrary string you can use to group
	 * sounds to mute or pan en masse.
	 */
	public var type(get, set):String;
	function get_type():String return _type;
	function set_type(value:String):String
	{
		if (_type == value) return value;
		if (playing)
		{
			removePlaying();
			_type = value;
			addPlaying();
			// reset, in case sound type has different settings
			pan = pan;
			volume = volume;
		}
		else
		{
			_type = value;
		}
		return value;
	}

	/**
	 * If the sound is currently playing.
	 */
	public var playing(get, null):Bool;
	inline function get_playing():Bool return _channel != null;

	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(get, null):Float;
	function get_position():Float return (playing ? _channel.position : _position) / 1000;

	/**
	 * Length of the sound, in seconds.
	 */
	public var length(get, null):Float;
	function get_length():Float return _sound.length / 1000;

	/**
	 * Return a sound type's pan setting.
	 * This factors in global panning. See `HXP.pan`.
	 *
	 * @param	type	The type to get the pan from.
	 *
	 * @return	The pan for the type.
	 */
	public static function getPan(type:String):Float
	{
		var result:Float = 0;
		if (_typeTransforms.exists(type))
		{
			var transform = _typeTransforms.get(type);
			if (transform != null)
			result = transform.pan;
		}
		return result + HXP.pan;
	}

	/**
	 * Return a sound type's volume setting.
	 * This factors in global volume. See `HXP.volume`.
	 *
	 * @param	type	The type to get the volume from.
	 *
	 * @return	The volume for the type.
	 */
	public static function getVolume(type:String):Float
	{
		var result:Float = 1;
		if (_typeTransforms.exists(type))
		{
			var transform = _typeTransforms.get(type);
			if (transform != null)
				result = transform.volume;
		}
		return result * HXP.volume;
	}

	/**
	 * Set a sound type's pan. Sfx instances of this type will add
	 * this pan to their own.
	 *
	 * @param	type	The type to set.
	 * @param	pan		The pan value.
	 */
	public static function setPan(type:String, pan:Float)
	{
		var transform:SoundTransform = _typeTransforms.get(type);
		if (transform == null)
		{
			transform = new SoundTransform();
			_typeTransforms.set(type, transform);
		}
		transform.pan = MathUtil.clamp(pan, -1, 1);

		if (_typePlaying.exists(type))
		{
			for (sfx in _typePlaying.get(type))
			{
				sfx.pan = sfx.pan;
			}
		}
	}

	/**
	 * Set a sound type's volume. Sfx instances of this type will
	 * multiply their volume by this value.
	 *
	 * @param	type	The type to set.
	 * @param	volume	The volume value.
	 */
	public static function setVolume(type:String, volume:Float)
	{
		var transform:SoundTransform = _typeTransforms.get(type);
		if (transform == null)
		{
			transform = new SoundTransform();
			_typeTransforms.set(type, transform);
		}
		transform.volume = volume < 0 ? 0 : volume;

		if (_typePlaying.exists(type))
		{
			for (sfx in _typePlaying.get(type))
			{
				sfx.volume = sfx.volume;
			}
		}
	}

	/**
	 * Called by `HXP` when global volume or panning are changed
	 * on native targets. Updates all sounds to the correct volume
	 * or pan, depending on the updatePan setting.
	 *
	 * @param	updatePan	True indicates pan changed, false indicates volume changed.
	 */
	public static function onGlobalUpdated(updatePan:Bool)
	{

	}

	// Sound infromation.
	var _type:String;
	var _volume:Float = 1;
	var _pan:Float = 0;
	var _filteredVol:Float;
	var _filteredPan:Float;
	var _sound:Sound;
	var _channel:SoundChannel;
	var _transform:SoundTransform;
	var _position:Float = 0;
	var _looping:Bool;

	// Stored Sound objects.
	static var _sounds:Map<String, Sound> = new Map<String, Sound>();
	static var _typePlaying:Map<String, Array<Sfx>> = new Map<String, Array<Sfx>>();
	static var _typeTransforms:Map<String, SoundTransform> = new Map<String, SoundTransform>();
}
