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
	public var camUnderlay:FlxCamera;
	public var camGame:SwagCamera;
	public var cams:Array<FlxCamera> = [];

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		camGame = new SwagCamera();
		camUnderlay = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camUnderlay, false);
		FlxG.cameras.add(camHUD, false);

		for (cam in [camGame, camHUD, camUnderlay])
		{
			cams.push(cam);
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		camUnderlay.zoom = camHUD.zoom;
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		if (FlxG.keys.justPressed.F5)
		{
			FlxG.resetState();
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
