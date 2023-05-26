package;

import lime.graphics.Image;
import lime.utils.Assets;
import lime.math.Rectangle;

class Sprite extends GameObject {
	private static var spriteData:Map<String, Spritesheet>;

	private var spritesheet:Spritesheet;
	private var rect:Rectangle;

	public override function new(name:String, parent:GameObject) {
		super(name, parent);
		if (spriteData == null) {
			spriteData = new Map();
		}
	}

	public override function destroy() {
		super.destroy();
	}

	public function load(file:String, pixelated:Bool = true):Sprite {
		setTexture(file + ".png", pixelated);
		setTexCoord(0, 0, 0, 0);

		if (spriteData[file] == null) {
			spriteData[file] = new Spritesheet(file);
		}
		spritesheet = spriteData[file];

		return this;
	}

	public function set(key:String):Sprite {
		if (spritesheet == null || spritesheet.get(key) == null) {
			return this;
		}

		rect = spritesheet.get(key);
		setTexCoord(rect.x, rect.y, rect.width, rect.height);

		return this;
	}

	public function center(horiz:Bool = true, vert:Bool = true) {
		if (rect == null) {
			return this;
		}

		if (horiz)
			pos_x = -rect.width * scale_x / 2;
		if (vert)
			pos_y = -rect.height * scale_y / 2;
		return this;
	}
}
