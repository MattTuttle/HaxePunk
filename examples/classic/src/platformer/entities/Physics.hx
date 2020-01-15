package platformer.entities;

import haxepunk.math.Vector2;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.math.MathUtil;

class Physics extends Entity
{

	// Define variables
	public var velocity:Vector2;
	public var acceleration:Vector2;
	public var friction:Vector2;
	public var maxVelocity:Vector2;
	public var gravity:Vector2;

	public static var solid:String = "solid";

	public function new(x:Float, y:Float)
	{
		super(x, y);
		_onGround = false;

		velocity     = new Vector2();
		acceleration = new Vector2();
		friction     = new Vector2();
		maxVelocity  = new Vector2();
		gravity      = new Vector2();
	}

	public var onGround(get, null): Bool;
	function get_onGround():Bool { return _onGround; }

	override public function update()
	{
		// Apply acceleration and velocity
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		applyVelocity();
		applyGravity();
		checkMaxVelocity();
		super.update();
	}

	public function applyGravity()
	{
		//increase velocity based on gravity
		velocity.x += gravity.x;
		velocity.y += gravity.y;
	}

	function checkMaxVelocity()
	{
		if (maxVelocity.x > 0 && Math.abs(velocity.x) > maxVelocity.x)
		{
			velocity.x = maxVelocity.x * MathUtil.sign(velocity.x);
		}

		if (maxVelocity.y > 0 && Math.abs(velocity.y) > maxVelocity.y)
		{
			velocity.y = maxVelocity.y * MathUtil.sign(velocity.y);
		}
	}

	override public function moveCollideY(e:Entity):Bool
	{
		if (velocity.y * MathUtil.sign(gravity.y) > 0)
		{
			_onGround = true;
		}
		velocity.y = 0;

		velocity.x *= friction.x;
		if (Math.abs(velocity.x) < 0.5) velocity.x = 0;
		return true;
	}

	override public function moveCollideX(e:Entity):Bool
	{
		velocity.x = 0;

		velocity.y *= friction.y;
		if (Math.abs(velocity.y) < 1) velocity.y = 0;
		return true;
	}

	function applyVelocity()
	{
		var i:Int;

		_onGround = false;

		moveBy(velocity.x, velocity.y, solid, true);
	}

	var _onGround:Bool;

}
