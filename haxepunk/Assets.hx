package haxepunk;

import haxe.ds.StringMap;
import haxe.io.Path;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class FileNode
{
	/**
	 * The name of the file or folder
	 */
	public var name:String;

	/**
	 * This is the full path on the device
	 */
	public var path:Null<String>;

	/**
	 * If this node is a folder
	 */
	public var isDirectory:Bool;

	var contents:StringMap<FileNode>;

	function new(name:String, isDirectory:Bool)
	{
		this.name = name;
		this.isDirectory = isDirectory;
		if (isDirectory)
		{
			contents = new StringMap<FileNode>();
		}
	}

	public function getChild(alias:String):Null<FileNode>
	{
		if (contents.exists(alias))
		{
			return contents.get(alias);
		}
		return null;
	}

	public function getOrCreateChild(alias:String, isDirectory:Bool):FileNode
	{
		var node:FileNode = getChild(alias);
		if (node == null)
		{
			node = new FileNode(alias, isDirectory);
			contents.set(alias, node);
		}
		return node;
	}

	public static function createRoot():FileNode
	{
		return new FileNode("", true);
	}
}

class Assets
{
	var root:FileNode;

	public function new()
	{
		root = FileNode.createRoot();
	}

	/**
	 * Add a path to the assets library. It will search for files and index them with an alias.
	 * @param path  The system path to search for assets.
	 * @param alias An alias for the path. If not provided, it will default to the top level folder name of the path variable.
	 */
	public function add(path:String, ?alias:String):Bool
	{
		if (!(FileSystem.exists(path) && FileSystem.isDirectory(path)))
		{
			return false;
		}

		var node = getNode(alias == null ? Path.withoutDirectory(path) : alias);
		addDirectoryToNode(node, path);

		return true;
	}

	/**
	 * Find the absolute file path based on the alias asset path
	 */
	public function getPath(alias:String):Null<String>
	{
		return getNode(alias, false).path;
	}

	/**
	 * Get the byte data of the asset
	 */
	public function getText(alias:String):Null<String>
	{
		var path = getPath(alias);
		return path == null ? #if (lime || nme) flash.Assets.getText(alias) #else null #end : File.getContent(path);
	}

	/**
	 * Get the byte data of the asset
	 */
	public function getBytes(alias:String):Null<Bytes>
	{
		var path = getPath(alias);
		return path == null ? null : File.getBytes(path);
	}

	function getNode(path:String, create:Bool=true):FileNode
	{
		var parts = Path.normalize(path.replace("\\", "/")).split("/");
		var node = root;
		for (name in parts)
		{
			// handle empty path segments and absolute paths
			if (name == "") continue;

			if (create)
			{
				node = node.getOrCreateChild(name, true);
			}
			else
			{
				node = node.getChild(name);
				if (node == null) return root;
			}
		}
		return node;
	}

	function addDirectoryToNode(parent:FileNode, path:String)
	{
		var assets = FileSystem.readDirectory(path);
		for (name in assets)
		{
			var newPath =  Path.join([path, name]);
			var node = parent.getOrCreateChild(name, FileSystem.isDirectory(newPath));
			if (node.isDirectory)
			{
				addDirectoryToNode(node, newPath);
			}
			else
			{
				node.path = newPath;
			}
		}
	}
}
