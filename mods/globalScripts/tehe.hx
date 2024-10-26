var spinLength = -100;

function onUpdatePost(elapsed:Float)
{
	if (spinLength < 30)
		spinLength += 10;
	var currentBeat = (FlxG.sound.music.time / 1000) * (Conductor.bpm / 60 * 0.3);
	game.playerStrums.forEach(function(receptor:StrumNote)
	{
		receptor.angle += (spinLength / 7) * -sin((currentBeat + receptor.noteData * 0.25) * 3.14159);
	//	receptor.x = 0 + spinLength * sin((currentBeat + receptor.noteData * 0.25) * 3.14159) + 600;
		receptor.y = 0 + spinLength * cos((currentBeat + receptor.noteData * 0.25) * 3.14159) + 50;
		

	});
}
