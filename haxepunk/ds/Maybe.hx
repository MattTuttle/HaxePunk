package haxepunk.ds;

abstract Maybe<T>(Null<T>) from Null<T>
{
	/**
	 * Check that the value exists
	 */
	public inline function exists():Bool return this != null;

	/**
	 * Enforces that the value exists or throws an error
	 */
	public inline function ensure():T return exists() ? this : throw "No value";

	/**
	 * Unsafe version of value. Make sure you check that the value exists if you aren't expecting a null.
	 */
	public inline function unsafe():Null<T> return this;

	/**
	 * Returns the value if exists or the default value provided.
	 */
	public inline function or(defaultValue:T):T return exists() ? this : defaultValue;

	/**
	 * Only call the provided function if the value exists.
	 */
	public inline function may(fn:T->Void):Void if (exists()) fn(this);

	/**
	 * If the value exists, call a function and return a value. Otherwise return the default value.
	 */
	public inline function map<S>(fn:T->S, defaultValue:S) return exists() ? fn(this) : defaultValue;
}
