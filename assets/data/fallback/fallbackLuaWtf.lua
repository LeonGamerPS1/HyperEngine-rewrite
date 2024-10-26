function onSongStart()
	for i = 0, 3 do
		j = (i + 4);

		iPos = _G['defaultPlayerStrumX' .. i];
		jPos = _G['defaultOpponentStrumX' .. i];

		noteTweenX('note'..i..'TwnX', i, iPos, 1, 'quadInOut');
		noteTweenX('note'..j..'TwnX', j, jPos, 1, 'quadInOut');

		noteTweenAngle('playerRotate0', 0, 360, 1, 'quartInOut');
		noteTweenAngle('playerRotate1', 1, 360, 1, 'quartInOut');
		noteTweenAngle('playerRotate2', 2, 360, 1, 'quartInOut');
		noteTweenAngle('playerRotate3', 3, 360, 1, 'quartInOut');

		noteTweenAngle('oppoRotate0', 4, 360, 1, 'quartInOut');
		noteTweenAngle('oppoRotate1', 5, 360, 1, 'quartInOut');
		noteTweenAngle('oppoRotate2', 6, 360, 1, 'quartInOut');
		noteTweenAngle('oppoRotate3', 7, 360, 1, 'quartInOut');
	end
	setProperty("iconP1.alpha", 0.00001)
end

function onUpdatePost()
	setProperty('iconP1.x', -593 + getProperty('healthBar.x') + (getProperty('healthBar.width') * (remapToRange(getProperty('healthBar.percent'), 0, -100, 100, 0) * 0.01)) - (150 * getProperty('iconP1.scale.x')) / 2 - 26 * 2)
	setProperty('iconP2.x', -593 + getProperty('healthBar.x') + (getProperty('healthBar.width') * (remapToRange(getProperty('healthBar.percent'), 0, -100, 100, 0) * 0.01)) + (150 * getProperty('iconP2.scale.x') -150) / 2 - 26)
	setProperty('iconP1.flipX', true)
	setProperty('iconP2.flipX', true)
	setProperty('healthBar.flipX', true)
	setProperty("iconP1.alpha", 0.00001)
end

function onBeatHit()
	if curBeat == 261 then
		setProperty("iconP1.alpha", 0.00001)
	end
end

function remapToRange(value, start1, stop1, start2, stop2)
	return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
end