package haxepunk.backend.flash;

#if (lime || nme)

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.Assets;
import haxepunk.math.MathUtil;
import haxepunk.Signal;

/**
 * Sound effect object used to play embedded sounds.
 */
class Sfx implements haxepunk.audio.Sfx
{
	/**
	 * Optional callback function for when the sound finishes playing.
	 */
	public var onComplete = new Signal0();

	/**
	 * Creates a sound effect from an embedded source. Store a reference to
	 * this object so that you can play the sound using play() or loop().
	 * @param	source		The embedded sound class to use.
	 * @param	complete	Optional callback function for when the sound finishes playing.
	 */
	public function new(source:String)
	{
		_transform = new SoundTransform();
		_volume = 1;
		_pan = 0;
		_position = 0;
		_type = "";

		if (source == null)
			throw "Invalid source Sound.";

		_sound = Assets.getSound(source);
		_sounds.set(source, _sound);
	}

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0)
	{
		_play(volume, pan, false);
	}

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	volume	Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(volume:Float = 1, pan:Float = 0)
	{
		_play(volume, pan, true);
	}

	// Internal play function
	function _play(volume:Float, pan:Float, loop:Bool)
	{
		if (_sound == null) return;
		if (playing) stop();
		_pan = MathUtil.clamp(pan, -1, 1);
		_volume = volume < 0 ? 0 : volume;
		_filteredPan = MathUtil.clamp(_pan + getPan(_type), -1, 1);
		_filteredVol = Math.max(0, _volume * getVolume(_type));
		_transform.pan = _filteredPan;
		_transform.volume = _filteredVol;
		_channel = _sound.play(0, loop ? -1 : 0, _transform);
		if (playing)
		{
			addPlaying();
			_channel.addEventListener(Event.SOUND_COMPLETE, onCompleteTrigger);
		}
		_looping = loop;
		_position = 0;
	}

	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool
	{
		if (!playing) return false;
		removePlaying();
		_position = _channel.position;
		_channel.removeEventListener(Event.SOUND_COMPLETE, onCompleteTrigger);
		_channel.stop();
		_channel = null;
		return true;
	}

	/**
	 * Resumes the sound from the position stop() was called on it.
	 */
	public function resume()
	{
		_channel = _sound.play(_position, _looping ? -1 : 0, _transform);
		if (playing)
		{
			addPlaying();
			_channel.addEventListener(Event.SOUND_COMPLETE, onCompleteTrigger);
		}
		_position = 0;
	}

	/** @private Event handler for sound completion. */
	function onCompleteTrigger(?e:Event)
	{
		if (_looping) loop(_volume, _pan);
		else stop();

		_position = 0;
		onComplete.invoke();
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
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	public var volume(get, set):Float;
	function get_volume():Float return _volume;
	function set_volume(value:Float):Float
	{
		if (value < 0) value = 0;
		if (_channel == null) return value;
		_volume = value;
		var filteredVol:Float = value * getVolume(_type);
		if (filteredVol < 0) filteredVol = 0;
		if (_filteredVol == filteredVol) return value;
		_filteredVol = _transform.volume = filteredVol;
		_channel.soundTransform = _transform;
		return _volume;
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
	public var isPlaying(get, never):Bool;
	inline function get_isPlaying():Bool return _channel != null;

	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(get, set):Float;
	function get_position():Float return (playing ? _channel.position : _position) / 1000;
	function set_position(value:Float) {
		if (playing)
		{
			return _channel.position = value * 1000;
		}
		else
		{
			return _position = value * 1000;
		}
	}

	/**
	 * Length of the sound, in seconds.
	 */
	public var length(get, never):Float;
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
		return result + HXP.app.audio.pan;
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
		return result * HXP.app.audio.volume;
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
		for (type in _typePlaying.keys())
		{
			for (sfx in _typePlaying.get(type))
			{
				if (updatePan)
				{
					sfx.pan = sfx.pan;
				}
				else
				{
					sfx.volume = sfx.volume;
				}
			}
		}
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

#end
