package haxepunk.masks;

import haxepunk.math.Vector3D;

class Sphere
{

	/**
	 * Position of the Sphere.
	 */
	public var position:Vector3D;

	/**
	 * Radius of the Sphere.
	 */
	public var radius:Float;

	public function new(?position:Vector3D, radius:Float=0)
	{
		this.position = (position == null ? new Vector3D() : position);
		this.radius = radius;
	}

	public function intersectsSphere(other:Sphere):Bool
	{
		var dx:Float = position.x - other.position.x;
		var dy:Float = position.y - other.position.y;
		var dz:Float = position.z - other.position.z;
		return (dx * dx + dy * dy + dz * dz) < Math.pow(radius + other.radius, 2);
	}

}
