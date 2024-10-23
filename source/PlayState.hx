package;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	public var cpuStrums:FlxTypedGroup<StrumNote>;
	override public function create()
	{
		super.create();
		cpuStrums = new  FlxTypedGroup<StrumNote>();
		for (i in 0...4) {
			var note:StrumNote = new StrumNote(50,50,i);
			note.x += StrumNote.swag * i;
			cpuStrums.add(note);
		}
		add(cpuStrums);
		
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
