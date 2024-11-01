package;

import flixel.text.FlxBitmapText;
import obj.StageData.StageFile;
import scripting.HScript;

@:publicFields
class PlayState extends MusicBeatState
{
	public static var storyWeek:Int = 1;

	public var cpuStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var downscroll:Bool = true;

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

	public var scripts:Array<HScript> = [];
	public var shaders:Array<shaders.BaseShader> = [];

	public var boyfriend:Boyfriend;
	public var gf:Character;
	public var dad:Character;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeed:Float = 1;

	var camPos:FlxPoint;

	public var camFollow:FlxObject;

	public static var prevCamFollow:FlxObject;

	var cameraRightSide:Bool = false;

	public var defaultCamZoom:Float = 1.05;
	public var cameraSpeed:Float = 1;

	override public function create()
	{
		if (SONG == null)
			SONG = Song.loadFromJson('duality-hard', 'duality');

		songSpeed = SONG.speed;

		instance = this;

		super.create();


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

		// persistentUpdate = true;
		// persistentDraw = true;

		notes = new FlxTypedGroup<Note>();
		holdCovers = new FlxTypedGroup<FlxSprite>();

		notes.cameras = [camHUD];
		holdCovers.cameras = [camHUD];

		call('onCreate');
		stagecum();

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		var ass = new ZShader();
		shaders.push(ass);
		// boyfriend.shader = ass;
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);


		gf = new Character(0, 0, SONG.player3);
		startCharacterPos(gf);
		gfGroup.add(gf);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(gf, true);
		dadGroup.add(dad);

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

			var note:StrumNote = new StrumNote(0, !downscroll ? 50 : FlxG.height - 150, i % 4, player);

			if (i < 4)
				cpuStrums.add(note);
			else
				playerStrums.add(note);

			holdCovers.add(note.holdCover);
			holdCovers.add(note.holdCoverEnd);
		}
		healthBarBG = new FlxSprite(0, downscroll ? FlxG.height * 0.11 : FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
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

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		// trace(SONG.player1);
		iconP1.cameras = [camHUD];
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.cameras = [camHUD];
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
	}

	function stagecum()
	{
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		// trace('stage is: ' + curStage);
		if (SONG.stage == null || SONG.stage.length < 1)
		{
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;
		trace(curStage);

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
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
		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		camFollow = new FlxObject(0, 0, 1, 1);

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		camGame.follow(camFollow, LOCKON, 0.04);
	}

	public function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			// char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
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
		for (strgroup in [playerStrums, cpuStrums])
			strgroup.forEach(function(str:StrumNote)
			{
				str.downScroll = downscroll;
			});

		if (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 2000 / SONG.speed)
		{
			var dunceNote:Note = unspawnNotes[0];
			if (dunceNote.isSustainNote)
				dunceNote.cameras = [camUnderlay];
			notes.add(dunceNote);

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.shift();
		}

		if (FlxG.sound.music.playing && SONG.notes[Std.int(curStep / 16)] != null)
		{
			cameraRightSide = SONG.notes[Std.int(curStep / 16)].mustHitSection;

			cameraMovement();
		}

		noteloop();

		keyShit();
		call('onUpdate', elapsed);
		for (index => shader in shaders)
		{
			shader.update(elapsed);
		}

		super.update(elapsed);

		Conductor.songPosition = FlxG.sound.music.time;
		camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, 0.9);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.9);
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

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	function cameraMovement()
	{
		if (camFollow.x != dad.getMidpoint().x + dad.cameraPosition[0] && !cameraRightSide)
		{
			camFollow.setPosition(dad.getMidpoint().x - 100, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			//	if (dad.curCharacter == 'mom')
			//		vocals.volume = 1;
		}

		if (cameraRightSide && boyfriend.x != boyfriend.getMidpoint().x - boyfriend.cameraPosition[0])
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
		}
	}

	function noteloop()
	{
		var fakeCrochet:Float = (60 / SONG.bpm) * 1000;

		notes.forEach(function(note:Note)
		{
			var strumGroup:FlxTypedGroup<StrumNote> = note.mustPress ? playerStrums : cpuStrums;
			var strumNote:StrumNote = strumGroup.members[note.noteData];
			var strumY:Float = strumNote.y;
			var strumX:Float = strumNote.x;

			var center:Float = strumY + StrumNote.swag;

			note.exists = note.isOnScreen(FlxG.camera);
			note.x = strumX + note.width * 0.225;

			var offset = !note.isSustainNote ? note.height * 0.225 : 0;
			note.y = !downscroll ? (strumY
				- (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)))
				+ offset : (strumY + (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2))) + offset;

			if (note.isSustainNote)
			{
				note.x += note.width * 1.5;
				note.flipY = downscroll;
				if (downscroll)
				{
					if (note.animation.curAnim.name.contains('end'))
					{
						note.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
						note.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;

						// note.y -= 19;
					}

					note.y += (StrumNote.swag / 2) - (60.5 * (songSpeed - 1));
					note.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
				}
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
				strumNote.playAnim('confirm');

				var animToPlay:String = '';
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
					case 1:
						animToPlay = 'singDOWN';
					case 2:
						animToPlay = 'singUP';
					case 3:
						animToPlay = 'singRIGHT';
				}
				dad.playAnim(animToPlay, true);
				dad.holdTimer = 0;

				var targetHold:Float = Conductor.stepCrochet * 0.001 * dad.singDuration;
				if (dad.holdTimer + 0.2 > targetHold)
				{
					dad.holdTimer = targetHold;
				}

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

			var animToPlay:String = '';
			switch (Std.int(Math.abs(note.noteData)))
			{
				case 0:
					animToPlay = 'singLEFT';
				case 1:
					animToPlay = 'singDOWN';
				case 2:
					animToPlay = 'singUP';
				case 3:
					animToPlay = 'singRIGHT';
			}
			boyfriend.playAnim(animToPlay, true);
			boyfriend.holdTimer = 0;

			var targetHold:Float = Conductor.stepCrochet * 0.001 * boyfriend.singDuration;
			if (boyfriend.holdTimer + 0.2 > targetHold)
			{
				boyfriend.holdTimer = targetHold;
			}

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

		for (char in [boyfriend, gf, dad])
		{
			if (char.holdTimer < 0.000001 && !char.animation.curAnim.name.contains('sing'))
				char.dance();
		}

		if (generatedMusic)
			notes.sort(Sort.sortNotes, FlxSort.DESCENDING);

		if (curBeat % 4 == 0)
		{
			camGame.zoom += 0.13;
			camHUD.zoom += 0.05;
		}
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
		if (boyfriend.animation.curAnim != null
			&& boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& !holdArray.contains(true))
		{
			boyfriend.dance();
			// boyfriend.animation.curAnim.finish();
		}

		if (dad.animation.curAnim != null
			&& dad.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * dad.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
		{
			dad.dance();
			// boyfriend.animation.curAnim.finish();
		}

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
		boyfriend.miss(direction);
		// FlxG.sound.play('assets/sounds/beep.ogg', FlxG.random.float(0.1, 0.2));
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
