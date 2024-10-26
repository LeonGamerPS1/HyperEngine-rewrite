package;

import flixel.text.FlxBitmapText;
import scripting.HScript;

@:publicFields
class PlayState extends MusicBeatState
{
	public static var storyWeek:Int = 1;

	public var cpuStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public static var SONG:SwagSong;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var downscroll:Bool = false;

	public var voice:FlxSound;

	var generatedMusic:Bool = false;

	var perfectMode:Bool = false;

	public var health:Float = 1;

	var practiceMode:Bool = false;
	var songScore:Int = 0;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var holdCovers:FlxTypedGroup<FlxSprite>;

	public static var seenCutscene:Bool = false;

	public static var yes:FlxBitmapText;

	public static var instance:PlayState;

	public var scripts:Array<HScript>;

	override public function create()
	{
		if (SONG == null)
			SONG = Song.loadFromJson('duality-hard', 'duality');

		instance = this;

		super.create();
		scripts = new Array<HScript>();

		if (Assets.exists('assets/data/${SONG.song.toLowerCase()}.hx'))
		{
			var hscript:HScript = new HScript('assets/data/${SONG.song.toLowerCase()}.hx', '${SONG.song.toLowerCase()}.hx');
			scripts.push(hscript);
		}
		recursiveLoop();

		FlxG.sound.cache('assets/songs/${SONG.song.toLowerCase()}/Inst.ogg');
		FlxG.sound.cache('assets/songs/${SONG.song.toLowerCase()}/Voices.ogg');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		persistentUpdate = true;
		persistentDraw = true;

		notes = new FlxTypedGroup<Note>();
		holdCovers = new FlxTypedGroup<FlxSprite>();

		notes.cameras = [camHUD];
		holdCovers.cameras = [camHUD];

		call('onCreate');
		previousCum();
		cummySongShit();

		FlxG.sound.playMusic('assets/songs/${SONG.song.toLowerCase()}/Inst.ogg');
		voice = new FlxSound();
		if (SONG.needsVoices)
			voice.loadEmbedded('assets/songs/${SONG.song.toLowerCase()}/Voices.ogg');

		voice.play();
		FlxG.sound.list.add(voice);
		generatedMusic = true;

		call('onCreatePost');
	}

	function previousCum()
	{
		cpuStrums = new FlxTypedGroup<StrumNote>();
		cpuStrums.cameras = [camHUD];
		add(cpuStrums);

		playerStrums = new FlxTypedGroup<StrumNote>();
		playerStrums.cameras = [camHUD];
		add(playerStrums);

		for (i in 0...8)
		{
			var player = i < 4 ? 0 : 1;

			var note:StrumNote = new StrumNote(0, 50, i % 4, player);

			if (i < 4)
				cpuStrums.add(note);
			else
				playerStrums.add(note);

			holdCovers.add(note.holdCover);
			holdCovers.add(note.holdCoverEnd);
		}
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.cameras = [camHUD];
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.cameras = [camHUD];
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		yes = new FlxBitmapText(healthBar.x + 500, healthBar.y + 35, "Loading Info...");
		yes.scale.set(2, 2);

		yes.cameras = [camHUD];
		add(yes);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.cameras = [camHUD];
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.cameras = [camHUD];
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
	}

	function cummySongShit()
	{
		var songData = SONG;

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var noteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(0, 0, daStrumTime, noteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				// swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.mustPress = gottaHitNote;

				if (susLength > 0)
				{
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(0, 0,
							daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), noteData,
							oldNote, true);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						sustainNote.mustPress = gottaHitNote;

						if (sustainNote.mustPress)
							sustainNote.x += FlxG.width / 2; // general offset
					}
				}
			}
		}
		unspawnNotes.sort(Sort.sortByShit);

		add(notes);
		add(holdCovers);
	}

	function recursiveLoop(directory:String = "./mods/globalScripts/")
	{
		#if sys
		if (sys.FileSystem.exists(directory))
		{
			trace("directory found: " + directory);
			for (file in sys.FileSystem.readDirectory(directory))
			{
				var path = haxe.io.Path.join([directory, file]);
				if (!sys.FileSystem.isDirectory(path))
				{
					if (path.endsWith('.hx'))
					{
						var hscript:HScript = new HScript(path, 'path', true);
						scripts.push(hscript);
					}

					// do something with file
				}
				else
				{
					var directory = haxe.io.Path.addTrailingSlash(path);
					trace("directory found: " + directory);
					recursiveLoop(directory);
				}
			}
		}
		else
		{
			trace('"$directory" does not exist');
		}
		#end
	}

	override public function update(elapsed:Float)
	{
		if (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 2000 / SONG.speed)
		{
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.shift();
		}

		noteloop();

		keyShit();
		call('onUpdate', elapsed);
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.9);

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.8)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.8)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		call('onUpdatePost', elapsed);

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */
	}

	function noteloop()
	{
		notes.forEach(function(note:Note)
		{
			var strumGroup:FlxTypedGroup<StrumNote> = note.mustPress ? playerStrums : cpuStrums;
			var strumNote:StrumNote = strumGroup.members[note.noteData];
			var strumY:Float = strumNote.y;
			var strumX:Float = strumNote.x;

			var center:Float = strumY + StrumNote.swag;

			note.exists = note.isOnScreen(FlxG.camera);
			note.x = strumX + note.width * 0.225;

			note.y = (strumY - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2))) + note.height * 0.225;
			if (note.isSustainNote)
			{
				note.x += note.width * 1.5;
				note.clipToStrumNote(strumNote);
			}

			if (!note.mustPress && note.wasGoodHit && !note.wasHit)
			{
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
					if (note.sustainLength > 0 && !note.isSustainNote)
						strumNote.holdAss = note.sustainLength * 0.9 / 1000;
				}
				// strumNote.playAnim('confirm');

				strumNote.resetAnim = Conductor.stepCrochet * 1.25 / 1000;
				note.wasHit = true;
			}
		});
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			/*
				if (!note.isSustainNote)
				{
					combo += 1;
					popUpScore(note.strumTime, note);
				}
			 */
			songScore += 50;

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			call('goodNoteHit', note.noteData, note.isSustainNote, note.mustPress);

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playAnim('confirm', true);
				}
			});

			note.wasGoodHit = true;
			voice.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		iconP1.setGraphicSize(Std.int(iconP1.width + 40));
		iconP2.setGraphicSize(Std.int(iconP2.width + 40));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		call('beatHit', curBeat);

		if (generatedMusic)
			notes.sort(Sort.sortNotes, FlxSort.DESCENDING);

		if (curBeat % 4 == 0)
			FlxG.camera.zoom += 0.05;
	}

	private function keyShit():Void
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var pressArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			controls.NOTE_LEFT_R,
			controls.NOTE_DOWN_R,
			controls.NOTE_UP_R,
			controls.NOTE_RIGHT_R
		];

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
				{
					var strum:StrumNote = playerStrums.members[daNote.noteData];
					goodNoteHit(daNote);
					strum.holdAss = FlxG.elapsed * 2;
					if (daNote.animation.curAnim.name.contains('end'))
					{
						strum.holdAss = 0.00000000000000000000000000000001;
						strum.splashfuck();
					}
				}
			});
		}
		// PRESSES, check for note hits
		if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			// boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = []; // notes that can be hit
			var directionList:Array<Int> = []; // directions that can be hit
			var dumbNotes:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{ // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{ // if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0)
			{
				for (shit in 0...pressArray.length)
				{ // if a direction is hit that shouldn't be
					if (pressArray[shit] && !directionList.contains(shit))
						noteMiss(shit);
				}
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			}
			else
			{
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit);
			}
		}
		/*
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
		 */
		FlxG.watch.addQuick('score', songScore);
		FlxG.watch.addQuick('song', SONG.song);

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.playAnim('press');
			if (!holdArray[spr.ID])
				spr.playAnim('static');
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		// whole function used to be encased in if (!boyfriend.stunned)
		health -= 0.04;
		killCombo();

		if (!practiceMode)
			songScore -= 10;

		voice.volume = 0;
		// FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		call('noteMiss', direction, songScore, practiceMode);
	}

	function killCombo() {}

	public function call(func:String, ?var1:Null<Any>, ?var2:Null<Any>, ?var3:Null<Any>)
	{
		for (i in 0...scripts.length)
		{
			var script:HScript = scripts[i];
			script.call(func, var1, var2, var3);
		}
	}
}
