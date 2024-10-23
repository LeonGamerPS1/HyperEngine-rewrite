package util;

class SprTil
{
	public static function sparrow(name:String, arg:FlxSprite)
	{
		arg.frames = FlxAtlasFrames.fromSparrow(image(name), xml(name));
	}

	public static function image(name:String):String
	{
		return 'assets/images/$name.png';
	}

	public static function xml(name:String):String
	{
		return 'assets/images/$name.xml';
	}
}
