package;

import flixel.FlxGame;
import haxe.macro.CompilationServer.ModuleCheckPolicy;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState));
		addChild(new FPS(5,5,0xFFFFFF));
	}
}
