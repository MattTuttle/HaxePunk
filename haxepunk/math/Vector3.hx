package haxepunk.math;

abstract Vector3 (Point3D)
{

	public static var ZERO:Vector3 = new Vector3(0, 0, 0);
	public static var X_AXIS = new Vector3(1);
	public static var Y_AXIS = new Vector3(0, 1);
	public static var Z_AXIS = new Vector3(0, 0, 1);

	public function new(x:Float=0, y:Float=0, z:Float=0)
	{
		this = new Point3D(x, y, z);
	}

	public var x(get, set):Float;
	private inline function get_x():Float return this.x;
	private inline function set_x(value:Float):Float return this.x = value;

	public var y(get, set):Float;
	private inline function get_y():Float return this.y;
	private inline function set_y(value:Float):Float return this.y = value;

	public var z(get, set):Float;
	private inline function get_z():Float return this.z;
	private inline function set_z(value:Float):Float return this.z = value;

	@:to
	public inline function toVector2():Vector2
	{
		return new Vector2(this.x, this.y);
	}

	/**
	 * Length of the vector
	 */
	public var length(get, never):Float;
	private function get_length():Float
	{
		return Math.sqrt(x * x + y * y + z * z);
	}

	public function clone():Vector3
	{
		return new Vector3(x, y, z);
	}

	/**
	 * Normalizes the vector
	 * @param length The length of the resulting vector
	 */
	public function normalize(length:Float=1):Void
	{
		var len = get_length();
		if (len > 0)
		{
			len = (1 / len) * length;
			x *= len;
			y *= len;
			z *= len;
		}
	}

	public function negate():Void
	{
		x = -x;
		y = -y;
		z = -z;
	}

	/**
	 * Distance between two vectors
	 * @param v Another vector to check distance
	 */
	public function distance(v:Vector3):Float
	{
		var dx = v.x - x;
		var dy = v.y - y;
		var dz = v.z - z;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	@:op(A += B) public static inline function add(a:Vector3, b:Vector3):Vector3
	{
		a.x += b.x;
		a.y += b.y;
		a.z += b.z;
		return a;
	}

	@:op(A + B) private static inline function _add(a:Vector3, b:Vector3):Vector3
	{
		return new Vector3(a.x + b.x, a.y + b.y, a.z + b.z);
	}

	@:op(A -= B) private static inline function subtract(a:Vector3, b:Vector3):Vector3
	{
		a.x -= b.x;
		a.y -= b.y;
		a.z -= b.z;
		return a;
	}

	@:op(A - B) private static inline function _subtract(a:Vector3, b:Vector3):Vector3
	{
		return new Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
	}

	@:commutative @:op(A * B) private static inline function _multiplyByScalar(a:Vector3, b:Float):Vector3
	{
		return new Vector3(a.x * b, a.y * b, a.z * b);
	}

	@:op(A *= B) private static inline function _multiplyEquals(a:Vector3, b:Float):Vector3
	{
		a.x *= b;
		a.y *= b;
		a.z *= b;
		return a;
	}

	@:op(A *= B) public static inline function multiply(a:Vector3, b:Vector3):Vector3
	{
		a.x *= b.x;
		a.y *= b.y;
		a.z *= b.z;
		return a;
	}

	@:op(A / B) private static inline function _divideByScalar(a:Vector3, b:Float):Vector3
	{
		b = 1 / b;
		return new Vector3(a.x * b, a.y * b, a.z * b);
	}

	@:op(A /= B) private static inline function _divideEquals(a:Vector3, b:Float):Vector3
	{
		b = 1 / b;
		a.x *= b;
		a.y *= b;
		a.z *= b;
		return a;
	}

	@:op(A /= B) public static inline function divide(a:Vector3, b:Vector3):Vector3
	{
		a.x /= b.x;
		a.y /= b.y;
		a.z /= b.z;
		return a;
	}

	public inline function cross(v:Vector3):Vector3
	{
		return new Vector3(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);
	}

	@:op(A % B) private static inline function _cross(a:Vector3, b:Vector3):Vector3
	{
		return a.cross(b);
	}

	@:op(A %= B) private static inline function _crossEquals(a:Vector3, b:Vector3):Vector3
	{
		var x = a.y * b.z - a.z * b.y;
		var y = a.z * b.x - a.x * b.z;
		var z = a.x * b.y - a.y * b.x;
		a.x = x;
		a.y = y;
		a.z = z;
		return a;
	}

	@:op(A *= B) private static inline function _multiplyEqualsMatrix(v:Vector3, m:Matrix4):Vector3
	{
		v.x = m._11 * v.x + m._12 * v.y + m._13 * v.z + m._41;
		v.y = m._21 * v.x + m._22 * v.y + m._23 * v.z + m._42;
		v.z = m._31 * v.x + m._32 * v.y + m._33 * v.z + m._43;
		return v;
	}

	@:op(A * B) private static inline function _multiplyMatrix(v:Vector3, m:Matrix4):Vector3
	{
		return new Vector3(
			m._11 * v.x + m._12 * v.y + m._13 * v.z + m._41,
			m._21 * v.x + m._22 * v.y + m._23 * v.z + m._42,
			m._31 * v.x + m._32 * v.y + m._33 * v.z + m._43
		);
	}

	@:op(A * B) private static inline function _multiplyInverseMatrix(m:Matrix4, v:Vector3):Vector3
	{
		return new Vector3(
			m._11 * v.x + m._21 * v.y + m._31 * v.z + m._41,
			m._12 * v.x + m._22 * v.y + m._32 * v.z + m._42,
			m._13 * v.x + m._23 * v.y + m._33 * v.z + m._43
		);
	}

	public inline function dot(v:Vector3):Float
	{
		return x * v.x + y * v.y + z * v.z;
	}

	@:op(A * B) private static inline function _dot(a:Vector3, b:Vector3):Float
	{
		return a.dot(b);
	}

	@:op(A == B) private static inline function _equals(a:Vector3, b:Vector3):Bool
	{
		return (a == null ? b == null : (b != null && a.x == b.x && a.y == b.y && a.z == b.z));
	}

	@:op(A != B) private static inline function _notEquals(a:Vector3, b:Vector3):Bool
	{
		return !_equals(a, b);
	}

	@:op(-A) private static inline function _negativeVector(a:Vector3):Vector3
	{
		return new Vector3(-a.x, -a.y, -a.z);
	}

}
