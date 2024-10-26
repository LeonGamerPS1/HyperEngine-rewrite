package scripting;

import hscript.Interp;
import hscript.Parser;

class HScript
{
	var parser:Parser;
	var interp:Interp;

	public function new(path:String, name:String, byte:Bool = false)
	{
		var expr:String;
		#if sys
		if (byte)
			expr = sys.io.File.read(path).readAll().toString();
		else
			expr = Assets.getText(path);
		#else
		expr = Assets.getText(path);
		#end
		parser = new hscript.Parser();
		parser.allowTypes = true;
		parser.allowMetadata = true;
		parser.allowJSON = true;
		parser.resumeErrors = true;
		var ast = parser.parseString(expr);

		interp = new hscript.Interp();

		set('game', PlayState.instance);
		set('camHUD', PlayState.instance.camHUD);
		set('FlxTween', flixel.tweens.FlxTween);
		set('iconP1', PlayState.instance.iconP1);
		set('iconP2', PlayState.instance.iconP2);

		set('Conductor', Conductor);

		set('FlxG', FlxG);
		// set('Math', Math);
		set('FlxMath', FlxMath);
		// set('setBotplay', PlayState.instance.sebotplay);
		set('sin', Math.sin);
		set('cos', Math.cos);
		/*
			set('getModSprite', function(val:String, txt:Bool = false)
			{
				return PlayState.instance.getLuaObject(val, txt);
			});

			set('createModSprite', function(tag:String, x:Int = 0, y:Int = 0)
			{
				var modchr:ModSprite;
				modchr = new ModSprite(x, y);
				PlayState.instance.modchartSprites.set(tag, modchr);
			});

		 */

		interp.execute(ast);
	}

	public function call(func:String, ?var1, ?var2, ?var3)
	{
		if (interp.variables.exists(func))
			interp.variables.get(func)(var1, var2, var3);
		else
			return;
	}

	public function set(obj:String, val:Dynamic)
	{
		interp.variables.set(obj, val);
	}
}
