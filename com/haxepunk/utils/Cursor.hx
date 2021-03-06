package com.haxepunk.utils;

class Cursor extends Entity
{
	/**
	 * Constructor.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 */
	override public function new(?graphic:Graphic, ?mask:Mask)
	{
		super(0, 0, graphic, mask);
	}

	/**
	 * Updates the entitiy coordinates to match the cursor.
	 */
	override public function update()
	{
		super.update();
		x = scene.mouseX;
		y = scene.mouseY;
	}

	/**
	 * Shows the custom cursor
	 */
	public function show()
	{
		visible = true;
	}

	/**
	 * Hides the custom cursor
	 */
	public function hide()
	{
		visible = false;
	}
}