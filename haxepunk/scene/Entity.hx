package haxepunk.scene;

import haxepunk.graphics.Graphic;
import haxepunk.masks.Mask;
import haxepunk.masks.AABB;
import haxepunk.math.Matrix3D;
import haxepunk.math.Vector3D;

class Entity
{

	public var position:Vector3D;

	public var x(get, set):Float;
	private inline function get_x():Float { return position.x; }
	private inline function set_x(value:Float) { return position.x = value; }

	public var y(get, set):Float;
	private inline function get_y():Float { return position.y; }
	private inline function set_y(value:Float) { return position.y = value; }

	public var z(get, set):Float;
	private inline function get_z():Float { return position.z; }
	private inline function set_z(value:Float) { return position.z = value; }

	public var layer(get, set):Float;
	private inline function get_layer():Float { return position.z; }
	private inline function set_layer(value:Float) { return position.z = value; }

	@:allow(haxepunk.scene.Scene)
	public var scene(default, null):Scene;

	public var hitbox:AABB;
	public var collidable:Bool = true;

	/**
	 * The collision type, used for collision checking.
	 */
	public var type(get, set):String;
	private inline function get_type():String { return _type; }
	private function set_type(value:String):String
	{
		if (_type != value)
		{
			if (scene == null)
			{
				_type = value;
			}
			else
			{
				if (_type != "") scene.removeType(this);
				_type = value;
				if (value != "") scene.addType(this);
			}
		}
		return _type;
	}

	/**
	 * The entity name
	 */
	public var name(get, set):String;
	private inline function get_name():String { return _name; }
	private function set_name(value:String):String
	{
		if (_name != value)
		{
			if (scene == null)
			{
				_name = value;
			}
			else
			{
				if (_name != "") scene.unregisterName(this);
				_name = value;
				if (value != "") scene.registerName(this);
			}
		}
		return _name;
	}

	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		position = new Vector3D(x, y, z);
		hitbox = new AABB();
		modelViewMatrix = new Matrix3D();
	}

	public function toString():String
	{
		return _name;
	}

	public function addGraphic(graphic:Graphic):Graphic
	{
		if (_graphic == null)
		{
			_graphic = graphic;
		}
		else if (Std.is(_graphic, GraphicList))
		{
			cast(_graphic, GraphicList).add(graphic);
		}
		else
		{
			_graphic = new GraphicList([_graphic, graphic]);
		}
		return _graphic;
	}

	public function draw(camera:Camera)
	{
		modelViewMatrix.identity();
		modelViewMatrix.translateVector3D(position);

		if (_graphic != null)
		{
			_graphic.draw(camera, modelViewMatrix);
		}
	}

	/**
	 * Checks for a collision against an Entity type.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collide(type:String, ?offset:Vector3D):Entity
	{
		// check that the entity has been added to a scene
		if (scene == null) return null;

		var entities = scene.entitiesForType(type);
		if (!collidable || entities == null) return null;

		var _x = hitbox.x, _y = hitbox.x;
		offset = (offset == null ? position : offset + position);
		hitbox.min += offset;
		hitbox.max += offset;

		for (e in entities)
		{
			if (e.collidable && e != this)
			{
				e.hitbox.min += e.position;
				e.hitbox.max += e.position;
				var result = e.hitbox.intersectsAABB(hitbox);
				e.hitbox.min -= e.position;
				e.hitbox.max -= e.position;

				if (result && (_mask == null || e._mask != null && _mask.intersects(e._mask)))
				{
					hitbox.min -= offset;
					hitbox.max -= offset;
					return e;
				}
			}
		}

		hitbox.min -= offset;
		hitbox.max -= offset;
		return null;
	}

	/**
	 * Updates the Entity.
	 */
	public function update(elapsed:Float):Void { }

	private var _graphic:Graphic;
	private var _mask:Mask;
	private var _type:String = "";
	private var _name:String = "";

	private var modelViewMatrix:Matrix3D;

}
