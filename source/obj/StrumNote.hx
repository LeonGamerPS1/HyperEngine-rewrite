package obj;

/**
 * ...
 * @author sexy bitch
 */
class StrumNote extends FlxSprite
{

	public static var swag:Float = 160 * 0.7;
	public static var dirArray:Array<String> = ["Left", "Down", "Up", "Right"];

	public function new(x:Float = 0, y:Float = 0, id:Int = 0)
	{
		super(x, y);
		this.ID = id;
		SprTil.sparrow('noteStrumline', this);
		setGraphicSize(width * 0.7);
		antialiasing = true;

		addAnimations(id);
		
	}

	@:noCompletion
	@:noPrivateAccess
	private function addAnimations(id:Int) {
        addAnim('static','static${dirArray[id]}');
		addAnim('confirm','confirm${dirArray[id]}');
		addAnim('confirmHold','confirmHold${dirArray[id]}');
		addAnim('press','press${dirArray[id]}');
		animation.play('static');
	}
	public  function addAnim(value:String,prefix:String,loop:Bool = false) {
		animation.addByPrefix(value,prefix,24,loop);
	}
}