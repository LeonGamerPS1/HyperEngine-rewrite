package obj;

import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * ...
 * @author sexy bitch
 */
class StrumNote extends FlxSprite
{
	public static var swag:Float = 160 * 0.7;
	public static var dirArray:Array<String> = ["Left", "Down", "Up", "Right"];

	public var noteData:Int = 0;

	public var player = 0;

	public var resetAnim:Float = 0;

	public var holdAss:Float = 0;

	public var sustainReduce:Bool = true;
	public var downScroll:Bool = false;

	public var rgbShader:RGBShaderReference;

	public var useRGBShader:Bool = true;

	var notedatas:Array<String> = ["Purple", "Blue", "Green", "Red"];

	var holdfolders = "hold/holdCover";

	public var holdCoverEnd:FlxSprite;

	public var holdCover:FlxSprite;

	public function new(x:Float = 0, y:Float = 0, id:Int = 0, plr:Int = 0)
	{
		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(noteData));

		super(x, y);

		this.ID = id;
		SprTil.sparrow('NOTE_assets', this);

		setGraphicSize(width * 0.7);
		antialiasing = true;

		noteData = id;
		player = plr;

		addAnimations(id);
		playerPosition();
		scrollFactor.set(0, 0);

		var arr:Array<FlxColor> = ClientPrefs.arrowRGB[noteData];

		if (noteData <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}
		playAnim('static');

		initHoldShit();
	}

	@:noCompletion
	@:noPrivateAccess
	private function initHoldShit()
	{
		holdCover = new FlxSprite(this.x + 25, this.y + 14);

		holdCoverEnd = new FlxSprite(this.x + 25, this.y + 14);

		SprTil.sparrow(holdfolders + notedatas[noteData], holdCover);
		SprTil.sparrow(holdfolders + notedatas[noteData], holdCoverEnd);

		holdCover.animation.addByPrefix('0', 'holdCover' + notedatas[noteData]);

		holdCover.animation.play('0');
		holdCover.offset.set(110, 93);

		holdCoverEnd.animation.addByPrefix('sicko', 'holdCoverEnd' + notedatas[noteData], 24, false);
		holdCoverEnd.animation.play('sicko');
		holdCoverEnd.offset.set(110, 93);
		holdCover.visible = false;
		holdCoverEnd.visible = false;
	}

	@:noCompletion
	@:noPrivateAccess
	private function addAnimations(id:Int)
	{
		addAnim('static', 'arrow');
		addAnim('confirm', 'confirm');
		addAnim('press', 'press');
		playAnim('static');
	}

	public function addAnim(value:String, prefix:String, loop:Bool = false)
	{
		animation.addByPrefix(value, prefix, 24, loop);
		// centerOffsets();
	}

	public function playerPosition()
	{
		x = 0;
		x += StrumNote.swag * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
	}
	public function splashfuck()
	{
		//	holdCoverEnd.visible = true;
		holdCoverEnd.animation.play('sicko');
		new FlxTimer().start((1 / 24) * 7, function(tmr:FlxTimer)
		{
			holdCoverEnd.visible = false;
		});
	}

	override function update(e:Float)
	{
		holdCover.setPosition(this.x + 25, this.y + 14);
		holdCoverEnd.setPosition(this.x + 25, this.y + 14);
		if (resetAnim > 0)
		{
			resetAnim -= e;

			if (resetAnim <= 0)
			{
				// centerOffsets();
				playAnim('static', true);

				// centerOffsets();
				resetAnim = 0;
			}
		}

		if (holdAss > 0)
		{
			holdAss -= e;
			// holdCover.visible = true;
			if (holdAss <= 0)
			{
				// centerOffsets();
				// trace("enemy hold daddy end.");
				holdCover.visible = false;
				if (player == 0)
					splashfuck();
				// centerOffsets();
				holdAss = 0;
			}
		}

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
		angle = a;
	}

	public function playAnim(?s:String = 'static', ?force:Bool = true)
	{
		animation.play(s, force);

		if (animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
		}
		if (useRGBShader)
			rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}
}

class RGBPalette
{
	public var shader(default, null):RGBPaletteShader = new RGBPaletteShader();
	public var r(default, set):FlxColor;
	public var g(default, set):FlxColor;
	public var b(default, set):FlxColor;
	public var mult(default, set):Float;

	private function set_r(color:FlxColor)
	{
		r = color;
		shader.r.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}

	private function set_g(color:FlxColor)
	{
		g = color;
		shader.g.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}

	private function set_b(color:FlxColor)
	{
		b = color;
		shader.b.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}

	private function set_mult(value:Float)
	{
		mult = FlxMath.bound(value, 0, 1);
		shader.mult.value = [mult];
		return mult;
	}

	public function new()
	{
		r = 0xFFFF0000;
		g = 0xFF00FF00;
		b = 0xFF0000FF;
		mult = 1.0;
	}
}

// automatic handler for easy usability
class RGBShaderReference
{
	public var r(default, set):FlxColor;
	public var g(default, set):FlxColor;
	public var b(default, set):FlxColor;
	public var mult(default, set):Float;
	public var enabled(default, set):Bool = true;

	public var parent:RGBPalette;

	private var _owner:FlxSprite;
	private var _original:RGBPalette;

	public function new(owner:FlxSprite, ref:RGBPalette)
	{
		parent = ref;
		_owner = owner;
		_original = ref;
		owner.shader = ref.shader;

		@:bypassAccessor
		{
			r = parent.r;
			g = parent.g;
			b = parent.b;
			mult = parent.mult;
		}
	}

	private function set_r(value:FlxColor)
	{
		if (allowNew && value != _original.r)
			cloneOriginal();
		return (r = parent.r = value);
	}

	private function set_g(value:FlxColor)
	{
		if (allowNew && value != _original.g)
			cloneOriginal();
		return (g = parent.g = value);
	}

	private function set_b(value:FlxColor)
	{
		if (allowNew && value != _original.b)
			cloneOriginal();
		return (b = parent.b = value);
	}

	private function set_mult(value:Float)
	{
		if (allowNew && value != _original.mult)
			cloneOriginal();
		return (mult = parent.mult = value);
	}

	private function set_enabled(value:Bool)
	{
		_owner.shader = value ? parent.shader : null;
		return (enabled = value);
	}

	public var allowNew = true;

	private function cloneOriginal()
	{
		if (allowNew)
		{
			allowNew = false;
			if (_original != parent)
				return;

			parent = new RGBPalette();
			parent.r = _original.r;
			parent.g = _original.g;
			parent.b = _original.b;
			parent.mult = _original.mult;
			_owner.shader = parent.shader;
			// trace('created new shader');
		}
	}
}

class RGBPaletteShader extends FlxAssets.FlxShader
{
	@:glFragmentHeader('
		#pragma header
		
		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;

		vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 coord) {
			vec4 color = flixel_texture2D(bitmap, coord);
			if (!hasTransform || color.a == 0.0 || mult == 0.0) {
				return color;
			}

			vec4 newColor = color;
			newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
			newColor.a = color.a;
			
			color = mix(color, newColor, mult);
			
			if(color.a > 0.0) {
				return vec4(color.rgb, color.a);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}')
	@:glFragmentSource('
		#pragma header

		void main() {
			gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
		}')
	public function new()
	{
		super();
	}
}
