import objects.HealthIcon;

var picoIcon = new HealthIcon('pico-duality2', true);
picoIcon.y = game.healthBar.y - 75;
picoIcon.cameras = [game.camHUD];
game.add(picoIcon);

var bfIcon = new HealthIcon('bf-duality2', true);
bfIcon.y = game.healthBar.y - 65;
bfIcon.cameras = [game.camHUD];
game.add(bfIcon);

function onBeatHit() {
	picoIcon.scale.set(1, 1);
	picoIcon.updateHitbox();

	bfIcon.scale.set(1, 1);
	bfIcon.updateHitbox();

	if (curBeat == 261) {
		picoIcon.changeIcon('pico-duality3');
		bfIcon.changeIcon('bf-duality');
	}
}

function onUpdate(elapsed:Float) {
	picoIcon.scale.set(game.iconP1.scale.x - 0.2, game.iconP1.scale.y - 0.2);
	picoIcon.updateHitbox();

	bfIcon.scale.set(game.iconP1.scale.x - 0.2, game.iconP1.scale.y - 0.2);
	bfIcon.updateHitbox();
}

function onUpdatePost() {
	var iconOffset:Int = 26;
	picoIcon.x = game.healthBar.barCenter + (150 * picoIcon.scale.x - 150) / 2 - iconOffset - 55;
	bfIcon.x = game.healthBar.barCenter + (150 * bfIcon.scale.x - 150) / 2 - iconOffset - 55;

	picoIcon.x = -600 + game.healthBar.x + game.healthBar.width * remapToRange(game.healthBar.percent, 0, -100, 100, 0) * 0.01 - 150 * picoIcon.scale.x / 2 - 26 * 2;
	picoIcon.flipX = true;

	bfIcon.x = -655 + game.healthBar.x + game.healthBar.width * remapToRange(game.healthBar.percent, 0, -100, 100, 0) * 0.01 - 150 * bfIcon.scale.x / 2 - 26 * 2;
	bfIcon.flipX = true;

	picoIcon.animation.curAnim.curFrame = (game.healthBar.percent < 20) ? 1 : 0;
	bfIcon.animation.curAnim.curFrame = (game.healthBar.percent < 20) ? 1 : 0;
}

function remapToRange(value, start1, stop1, start2, stop2) {
	return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1));
}