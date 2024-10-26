package;

import backend.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import song.Conductor.BPMChangeEvent;

class MusicBeatState extends FlxUIState
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var controls(get, never):Controls;

	public var camHUD:FlxCamera;
	public var camGame:SwagCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		camGame = new SwagCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		if (FlxG.keys.justPressed.F5)
		{
			camGame.alpha = 0.6;
			var text:FlxText = new FlxText(0, 0, 0, 'Reloading...', 20);
			text.screenCenter();
			text.cameras = [camHUD];
			var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height,FlxColor.GRAY);
			bg.cameras = [camHUD];
			bg.alpha = 0.7;
			add(bg);
			add(text);
			new FlxTimer().start(0.5, (tmr:FlxTimer) -> FlxG.resetState());
		}
		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
