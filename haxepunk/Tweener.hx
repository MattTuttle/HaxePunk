package haxepunk;

import haxepunk.Tween;
import haxepunk.ds.Maybe;

/**
 * Abstract class used to add the ability to add tweens.
 */
@:access(haxepunk.Tween)
class Tweener
{
	@:isVar public var active(get, set):Bool = true;
	function get_active() return active;
	function set_active(v:Bool) return active = v;

	public var autoClear:Bool = false;

	@:allow(haxepunk)
	function new() {}

	@:dox(hide)
	public function update() {}

	/**
	 * Add the tween to the tween list.
	 *
	 * @param	t		The tween to add.
	 * @param	start	If the tween should start immediately.
	 *
	 * @return	The added tween.
	 */
	public function addTween(t:Tween, start:Bool = false):Tween
	{
		if (t._parent != null)
			throw "Cannot add a Tween object more than once.";

		t._parent = this;
		t._next = _tween;

		_tween.may((tween) -> tween._prev = t);

		_tween = t;

		if (start)
			t.start();
		else
			t.active = false;

		return t;
	}

	/**
	 * Remove the tween from the tween list.
	 *
	 * @param	t		The tween to remove.
	 *
	 * @return	The removed tween.
	 */
	public function removeTween(t:Tween):Tween
	{
		if (t._parent != this)
			throw "Core object does not contain Tween.";

		t._next.may((n) -> n._prev = t._prev);
		t._prev.may((p) -> p._next = t._next);

		if (_tween == t)
		{
			_tween = t._next;
		}
		t._next = t._prev = null;
		t._parent = null;
		t.active = false;
		return t;
	}

	/**
	 * Remove all tweens from the tween list.
	 */
	public function clearTweens()
	{
		while (_tween.exists())
		{
			removeTween(_tween.unsafe());
		}
	}

	/**
	 * Update all contained tweens.
	 */
	public function updateTweens(elapsed:Float)
	{
		var t:Null<Tween> = _tween.unsafe();
		while (t != null)
		{
			if (t.active)
			{
				t.update(elapsed);
			}
			t = t._next.unsafe();
		}
	}

	/** If there is at least a tween. */
	public var hasTween(get, never):Bool;
	function get_hasTween():Bool return _tween.exists();

	var _tween:Maybe<Tween>;
}
