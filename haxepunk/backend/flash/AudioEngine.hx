package haxepunk.backend.flash;

class AudioEngine implements haxepunk.audio.AudioEngine
{
	public function new()
	{
	}

	public function stop(sfx:Sfx):Bool
	{
		if (!playing) return false;
		removePlaying();
		_position = _channel.position;
		_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
		_channel.stop();
		_channel = null;
		return true;
	}

	public function play(sfx:Sfx, loop:Bool=false):Bool
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
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}
		_looping = loop;
		_position = 0;
	}

	public function resume(sfx:Sfx):Bool
	{
		_channel = _sound.play(_position, _looping ? -1 : 0, _transform);
		if (playing)
		{
			addPlaying();
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}
		_position = 0;
	}

	public function setVolume(sfx:Sfx, volume:Float):Float
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

	public function update():Void
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

	public function quit():Void
	{

	}
}
