package;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PlayState extends FlxState
{
	public var cpuStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	override public function create()
	{
		super.create();
		cpuStrums = new FlxTypedGroup<StrumNote>();
		for (i in 0...4)
		{
			var note:StrumNote = new StrumNote(0, 50, i, 0);
			// note.x += StrumNote.swag * i;
			cpuStrums.add(note);
			note.y -= 50;
			note.alpha = 0;
			FlxTween.tween(note, {y: note.y + 50, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
		}
		add(cpuStrums);

		playerStrums = new FlxTypedGroup<StrumNote>();
		for (i in 0...4)
		{
			var note:StrumNote = new StrumNote(0, 50, i, 1);
			// note.x += StrumNote.swag * i;
			playerStrums.add(note);

			note.y -= 50;
			note.alpha = 0;
			FlxTween.tween(note, {y: note.y + 50, alpha: 1}, 1, {
				ease: FlxEase.circOut,
				startDelay: 0.5 + (0.2 * i),
				onComplete: function(t:FlxTween)
				{
					note.animation.play('confirmHold');
				}
			});
		}
		add(playerStrums);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
