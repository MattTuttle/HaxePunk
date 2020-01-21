package haxepunk.graphics.shader;

enum AttributeType
{
	Position;
	TexCoord;
	VertexColor;
	Custom(floatsPerElement:Int);
}

class Attribute
{
	public final name:String;
	public final type:AttributeType;
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

class Shader
{
	public var vertexSource:String;
	public var fragmentSource:String;

	public final id:Int;
	static var idSeq:Int = 0;

	/**
	 * Override check if triangles are on screen
	 */
	public var alwaysDraw:Bool = false;

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
