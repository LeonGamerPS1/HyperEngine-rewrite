import StringTools;

var dearestDuality = new Character(925, 85, 'dad-duality-2', true);
game.startCharacterPos(dearestDuality, true);
game.add(dearestDuality);

var chars = [
	"Dad Duality Sing" => dearestDuality,
	"Duality Parents Duet" => dearestDuality
];

for (name in chars.keys()) {
	game.variables.set(name, chars[name]);
}

function onCreatePost() {
	for (note in game.unspawnNotes) {
		for (name in chars.keys()) {
			if (note.noteType == name) {
				note.noAnimation = true;
				note.noMissAnimation = true;
			}

			if (note.noteType == "Duality Parents Duet") {
				note.noAnimation = false;
				note.noMissAnimation = true;
			}
		}
	}
}

function onCountdownStarted() {
	new FlxTimer().start(Conductor.crochet / 1000 / game.playbackRate, function(tmr) {
		for (char in chars) {
			if (tmr.loopsLeft % char.danceEveryNumBeats == 0 && char.animation.curAnim != null && !StringTools.startsWith(char.animation.curAnim.name, "sing") && !char.stunned) {
				char.dance();
			}
		}
	}, 5);
}

function onBeatHit(){
	for (char in chars) {
		if (curBeat % char.danceEveryNumBeats == 0 && char.animation.curAnim != null && !StringTools.startsWith(char.animation.curAnim.name, "sing") && !char.stunned) {
			char.dance();
		}
	}

	if (curBeat == 260) {
		game.remove(dearestDuality);
		dearestDuality = new Character(925, 85, 'dad-duality', true);
		game.startCharacterPos(dearestDuality, true);
		game.add(dearestDuality);

		chars = [
			"Dad Duality Sing" => dearestDuality,
			"Duality Parents Duet" => dearestDuality
		];
	}

	if (curBeat == 544) {
		dearestDuality.color = FlxColor.BLACK;
	}
}

function opponentNoteHit(note) {
	if (chars[note.noteType] != null) {
		var char = chars[note.noteType];
		var anim = ["singLEFT", "singDOWN", "singUP", "singRIGHT"][note.noteData % 4];
		char.playAnim(anim, true);
		char.holdTimer = 0;
	}
}

function onUpdatePost() {
	if (game.generatedMusic && !game.inCutscene && game.startedCountdown) {
		for (char in chars) {
			if (!char.stunned && char.animation.curAnim != null && char.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * char.singDuration && StringTools.startsWith(char.animation.curAnim.name, "sing") && !StringTools.endsWith(char.animation.curAnim.name, "miss")) {
				char.dance();
			}
		}
	}
}