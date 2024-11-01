package shaders;

import flixel.system.FlxAssets.FlxShader;

class BaseShader extends FlxShader
{
	public var time:Float = 0;

	public function new()
	{
		super();
	}

	/**
	 * The Update Function.
	 * @param elapsed  The Time between frames (in MS.)
	 */
	public function update(elapsed:Float)
	{
		time += elapsed;
		
	}
}
