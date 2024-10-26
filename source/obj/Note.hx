package obj;

import flixel.util.FlxColor;
import obj.StrumNote.RGBPalette;
import obj.StrumNote.RGBShaderReference;

class Note extends FlxSprite
{
	public var noteData:Int = 0;
	public var prevNote:Note;
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;

	public var sustainLength:Float = 0;

	public var wasGoodHit:Bool = false;

	public var isSustainNote:Bool = false;
	public var ignoreNote:Bool = false;

	public var canBeHit:Bool = false;

	private var earlyHitMult:Float = 0.5;

	public var tooLate:Bool = false;

	public var wasHit:Bool = false;

	public var rgbShader:RGBShaderReference;

	public static var globalRgbShaders:Array<RGBPalette> = [];

	public function new(x:Float = 0, y:Float = 0, strumTime:Float = 0, noteData:Int = 0, ?prevNote:Note, ?isSustainNote:Bool = false)
	{
		this.noteData = noteData;
		this.ID = noteData;

		this.strumTime = strumTime;

		this.prevNote = prevNote != null ? prevNote : null;

		this.isSustainNote = isSustainNote;

		super(x, y);

		SprTil.sparrow('NOTE_assets', this);
		setGraphicSize(width * 0.7);
		offset.x += width / 2;

		antialiasing = true;
		addAnimations(noteData);

		updateHitbox();
		scrollFactor.set(0, 0);

		if (isSustainNote && prevNote != null)
		{
			
			animation.play('end');
			updateHitbox();
			alpha = 1;
			

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('hold');

				prevNote.alpha = alpha;
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		if (noteData > -1)
		{
			rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(noteData));
		}
	}

	public function defaultRGB()
	{
		var arr:Array<FlxColor> = ClientPrefs.arrowRGB[noteData];

		if (arr != null && noteData > -1 && noteData <= arr.length)
		{
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}
		else
		{
			rgbShader.r = 0xFFFF0000;
			rgbShader.g = 0xFF00FF00;
			rgbShader.b = 0xFF0000FF;
		}
	}

	public static function initializeGlobalRGBShader(noteData:Int)
	{
		if (globalRgbShaders[noteData] == null)
		{
			var newRGB:RGBPalette = new RGBPalette();
			var arr:Array<FlxColor> = ClientPrefs.arrowRGB[noteData];

			if (arr != null && noteData > -1 && noteData <= arr.length)
			{
				newRGB.r = arr[0];
				newRGB.g = arr[1];
				newRGB.b = arr[2];
			}
			else
			{
				newRGB.r = 0xFFFF0000;
				newRGB.g = 0xFF00FF00;
				newRGB.b = 0xFF0000FF;
			}

			globalRgbShaders[noteData] = newRGB;
		}
		return globalRgbShaders[noteData];
	}

	override function update(e:Float)
	{
		super.update(e);
		var a = 0;
		switch (noteData)
		{
			case 0:
				a = 90;
			case 1:
				a = 0;
			case 2:
				a = 180;
			case 3:
				a = -90;
		}
		if (!isSustainNote)
			angle = a;

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}
	}

	@:noCompletion
	@:noPrivateAccess
	private function addAnimations(id:Int)
	{
		addAnim('note', 'note');
		addAnim('hold', 'hold');
		addAnim('end', 'end');
		animation.play(isSustainNote ? 'hold' : 'note');
	}

	public function addAnim(value:String, prefix:String, loop:Bool = false)
	{
		animation.addByPrefix(value, prefix, 24, loop);
	}

	public function clipToStrumNote(myStrum:StrumNote)
	{
		var center:Float = myStrum.y + 0 + StrumNote.swag / 1.6;
		if (isSustainNote && (mustPress || !ignoreNote) && (!mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit))))
		{
			var swagRect:FlxRect = clipRect;
			if (swagRect == null)
				swagRect = new FlxRect(0, 0, frameWidth, frameHeight);

			if (myStrum.downScroll)
			{
				if (y - offset.y * scale.y + height >= center)
				{
					swagRect.width = frameWidth;
					swagRect.height = (center - y) / scale.y;
					swagRect.y = frameHeight - swagRect.height;
				}
			}
			else if (y + offset.y * scale.y <= center)
			{
				swagRect.y = (center - y) / scale.y;
				swagRect.width = width / scale.x;
				swagRect.height = (height / scale.y) - swagRect.y;
			}
			clipRect = swagRect;
		}
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}
}
