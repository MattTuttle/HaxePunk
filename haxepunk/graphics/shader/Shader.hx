package haxepunk.graphics.shader;

/**
 * The shader attribute data type. This is the data that will be stored in a shader
 * attribute. Position, texture coordinates, and vertex colors are automatic but
 * custom data can also be attached to a shader.
 */
enum AttributeType
{
	Position;
	TexCoord;
	VertexColor;
	/**
	 * The floatsPerElement parameter sets the number of floats per vertex.
	 * This will allow a single float per vertex up to an entire matrix.
	 * Remember you need to set the data on the Attribute instance.
	 */
	Custom(floatsPerElement:Int);
}

/**
 * Class to keep track of shader attributes. Do not create an instance of this directly.
 * Instead, create attributes on shaders by calling the Shader.addAttribute function.
 */
class Attribute
{
	public final name:String;
	public final type:AttributeType;
	/**
	 * Only used for the Custom attribute type. You must populate this with data
	 * when using the custom type.
	 */
	public final data:Array<Float>;

	function new(name:String, type:AttributeType)
	{
		this.name = name;
		this.type = type;
		switch (type)
		{
			case Custom(_): data = new Array<Float>();
			default: // no data
		}
	}
}

/**
 * Allows the creation of shaders by passing the vertex and fragment source on creation.
 * There is no cross-compilation so shaders are platform specific.
 */
class Shader
{
	@:dox(hide)
	public final vertexSource:String;

	@:dox(hide)
	public final fragmentSource:String;

	@:dox(hide)
	public final id:Int;
	static var idSeq:Int = 0;

	/**
	 * Override check if triangles are on screen. This will automatically be set
	 * if a custom attribute is used.
	 */
	public var alwaysDraw:Bool = false;

	/**
	 * Can be used to turn on and off the shader from being used for post processing.
	 * Only useful for scene shaders.
	 */
	public var active:Bool = true;

	/**
	 * Changes the filtering method used on the render texture.
	 * Defaults to pixelated (nearest neighbor).
	 * Only useful for scene shaders.
	 */
	public var smooth:Bool = false;

	public function new(vertexSource:String, fragmentSource:String)
	{
		this.vertexSource = vertexSource;
		this.fragmentSource = fragmentSource;

		id = idSeq++;

		Log.info('Shader #$idSeq initialized');
	}

	/**
	 * Add an attribute definition to the shader. Custom attributes must be populated with data after
	 * adding them to the shader. Use the returned attribute instance and set the data field appropriately.
	 * @name The name of the attribute in the shader source
	 * @type The type of data to populate this attribute (position, tex coord, color, or custom)
	 */
	@:access(haxepunk.graphics.shader.Attribute)
	public function addAttribute(name:String, type:AttributeType):Attribute
	{
		// Keeping old functionality that forces everything to draw when custom attributes are added
		switch (type)
		{
			case Custom(_): alwaysDraw = true;
			default: // do nothing
		}
		var attribute = new Attribute(name, type);
		attributes.push(attribute);
		dirty = true;
		return attribute;
	}

	/**
	 * Set or change the value of a named shader uniform.
	 * Currently only supports single float values.
	 */
	public inline function setUniform(name:String, value:Float)
	{
		if (!uniformValues.exists(name))
		{
			uniformNames.push(name);
		}
		uniformValues[name] = value;
	}

	var dirty = true;

	var attributes = new Array<Attribute>();

	var uniformNames:Array<String> = new Array();
	var uniformValues:Map<String, Float> = new Map();
}
