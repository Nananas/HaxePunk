package haxepunk.input;

import haxe.ds.IntMap;
import lime.ui.MouseEventManager;

import haxepunk.input.Input;

/**
 * The mouse buttons.
 * To be used with Input.define, Input.check, Input.pressed, Input.released and Mouse.nameOf.
 *
 * Warning: ANY also encompass buttons that aren't listed here, for mouse with more than 3 buttons.
 */
@:enum abstract MouseButton(Int) to Int
{
	var ANY = -1;
	var LEFT = 0;
	var MIDDLE = 1;
	var RIGHT = 2;

	@:op(A<B) private inline function less (rhs:Int):Bool { return this < rhs; }
	@:op(A>B) private inline function more (rhs:Int):Bool { return this > rhs; }
}

/**
 * Store the values on, pressed and released for a mouse button.
 */
private class MouseState
{
	public var on:Int = 0;
	public var pressed:Int = 0;
	public var released:Int = 0;

	public function new() { }

	public function value(v:InputValue):Int
	{
		return switch (v)
		{
			case InputValue.On: return on;
			case InputValue.Pressed: return pressed;
			case InputValue.Released: return released;
		};
	}
}

/**
 * Get information on the mouse input.
 */
class Mouse
{
	/** Holds the last mouse button detected */
	public static var last(default, null):MouseButton = MouseButton.ANY;

	/** The delta of the mouse wheel on the horizontal axis, 0 if it wasn't moved this frame */
	public static var wheelDeltaX(default, null):Float = 0;

	/** The delta of the mouse wheel on the vertical axis, 0 if it wasn't moved this frame */
	public static var wheelDeltaY(default, null):Float = 0;

	/** X position of the mouse on the screen */
	public static var x(default, null):Float = 0;

	/** Y position of the mouse on the screen */
	public static var y(default, null):Float = 0;

	/**
	 * Returns the name of the mouse button.
	 *
	 * Examples:
	 * Mouse.nameOf(MouseButton.LEFT);
	 * Mouse.nameOf(Mouse.last);
	 *
	 * @param button The mouse button to name
	 * @return The name
	 */
	public static function nameOf(button:MouseButton):String
	{
		if (button > 2) // The button isn't defined in MouseButton
		{
			var v:Int = cast button;
			return "BUTTON " + v;
		}

		return switch(button)
		{
			case ANY:
				"";

			case LEFT:
				"LEFT";

			case MIDDLE:
				"MIDDLE";

			case RIGHT:
				"RIGHT";
		}
	}



	/**
	 * Setup the mouse input support.
	 */
	@:allow(haxepunk.input.Input)
	private static function init():Void
	{
		// Register the events from lime
		MouseEventManager.onMouseMove.add(onMouseMove);
		MouseEventManager.onMouseDown.add(onMouseDown);
		MouseEventManager.onMouseUp.add(onMouseUp);
		MouseEventManager.onMouseWheel.add(onMouseWheel);
	}

	/**
	 * Return the value for a mouse button.
	 *
	 * @param button The mouse button to check
	 * @param v The value to get
	 * @return The value of [v] for [button]
	 */
	@:allow(haxepunk.input.Input)
	private static inline function value(button:MouseButton, v:InputValue):Int
	{
		if (button < 0) // Any
		{
			var result = 0;
			for (state in _states)
			{
				result += state.value(v);
			}
			return result;
		}
		else
		{
			return getMouseState(cast button).value(v);
		}
	}

	/**
	 * Updates the mouse state.
	 */
	@:allow(haxepunk.input.Input)
	private static function update():Void
	{
		// Was On last frame if was on the previous one and there is at least the same amount of Pressed than Released.
		// Or wasn't On last frame and Pressed > 0
		for (state in _states)
		{
			state.on = ( (state.on > 0 && state.pressed >= state.released) || (state.on == 0 && state.pressed > 0) ) ? 1 : 0;
			state.pressed = 0;
			state.released = 0;
		}

		// Reset wheelDelta
		wheelDeltaX = wheelDeltaY = 0;
	}

	/**
	 * Lime onMouseMove event.
	 */
	private static inline function onMouseMove(x:Float, y:Float, button:Int):Void
	{
		Mouse.x = x;
		Mouse.y = y;
	}

	/**
	 * Lime onMouseDown event.
	 */
	private static function onMouseDown(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y, button);

		getMouseState(button).pressed += 1;
		last = cast button;
	}

	/**
	 * Lime onMouseUp event.
	 */
	private static function onMouseUp(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y, button);

		getMouseState(button).released += 1;
		last = cast button;
	}

	/**
	 * Lime onMouseWheel event.
	 */
	private static function onMouseWheel(deltaX:Float, deltaY:Float):Void
	{
		wheelDeltaX = deltaX;
		wheelDeltaY = deltaY;
	}

	/**
	 * Gets a mouse state object from a button number.
	 */
	private static function getMouseState(button:Int):MouseState
	{
		var state:MouseState;
		if (_states.exists(button))
		{
			state = _states.get(button);
		}
		else
		{
			state = new MouseState();
			_states.set(button, state);
		}
		return state;
	}

	/** States for On,Pressed,Released for each button */
	private static var _states:IntMap<MouseState> = new IntMap<MouseState>();
}
