package;

import lime.graphics.Image;
import lime.utils.Assets;

class Text extends GameObject {
	private var strText:String = "";
	private var fontImage:Image;
	private var fontData:Map<Int, Array<Int>>;
	private var wrapWidth:Int = 0;
	private var wrapHeight:Int = 0;
	private var lineHeight:Int = 32;

	private var textWidth:Int = 0;
	private var textHeight:Int = 0;

	public override function new(name:String, parent:GameObject) {
		super(name, parent);
	}

	public override function destroy() {
		super.destroy();
		fontImage = null;
		fontData = null;
	}

	private function drawChar(code:Int, c:GameObject, px:Float, py:Float):Int {
		var info = fontData[code];

		if (info != null && fontImage != null) {
			var x = info[1];
			var y = info[2];
			var w = info[3];
			var h = info[4];
			var xoff = info[5];
			var yoff = info[6];
			var xadv = info[7];

			c.texture = fontImage;
			c.setTexCoord(x, y, w, h);
			c.setPosition(px + xoff, py + yoff);
			c.visible = true;

			return xadv;
		}

		return 0;
	}

	private function wrapWord(word:Array<GameObject>) {
		var px = 0.0;
		var first = true;

		for (c in word) {
			if (first) {
				px = c.pos_x;
				first = false;
			}
			c.pos_x -= px;
			c.pos_y += lineHeight;
		}
	}

	public function setText(str:String):Text {
		strText = str;
		textWidth = 0;
		textHeight = 0;

		if (fontData != null && fontImage != null) {
			var px = 0;
			var py = 0;

			// add new render objects
			var len = (strText.length - children.length);
			for (i in 0...len) {
				new GameObject("ch" + children.length, this);
			}

			var word = [];
			var wordWidth = 0;
			var wordStart = 0;
			var wrap = false;
			var i = 0;

			// go through render objects
			for (c in children) {
				if (wrapHeight > 0 && textHeight > wrapHeight) {
					c.visible = false;
					continue;
				}
				if (i >= strText.length) {
					c.visible = false;
					continue;
				}

				var code = strText.charCodeAt(i);
				px += drawChar(code, c, px, py);

				if (wrapWidth > 0) {
					word.push(c);
					wordWidth = px - wordStart;
				}

				if (code == 10) // line break
				{
					if (wrap == true && wordWidth < wrapWidth) {
						py += lineHeight;
						px = wordWidth;
						wrapWord(word);
					}
					px = 0;
					py += lineHeight;
					wrap = false;
				} else if (wrapWidth > 0 && code == 32) // space
				{
					if (wrap == true && wordWidth < wrapWidth) {
						py += lineHeight;
						px = wordWidth;
						wrapWord(word);
					}
					word = [];
					wordWidth = 0;
					wordStart = px;
					wrap = false;
				} else if (wrapWidth > 0 && px >= wrapWidth) {
					wrap = true;
				}

				++i;

				textHeight = Math.floor(py + lineHeight / 2);
				if (wrap == false) {
					textWidth = Utils.max(textWidth, px);
				}
			}

			word = null;
		}

		return this;
	}

	public function setTextFade(len:Float):Float {
		var sum = len;
		var i = 0;

		for (c in children) {
			if (i >= strText.length) {
				break;
			}

			c.setAlpha(sum);
			sum = Math.max(0, sum - 1.0);

			++i;
		}

		return len / strText.length;
	}

	public function clearTextFade() {
		setTextFade(1.0 * strText.length);
	}

	private function parseFontData(line:String) {
		var a = line.split(" ");
		var result = [];
		for (d in a) {
			var ad = d.split("=");
			if (ad.length == 2) {
				var v = Utils.getInt(ad[1]);
				result.push(v);
			}
		}

		return result;
	}

	public function setFont(file:String, scale:Float = 1.0):Text {
		setScale(scale, scale);

		var img = Assets.getImage(file + ".png");
		if (img == null || img == fontImage) {
			return this;
		}
		fontImage = img;

		var fnt = Assets.getText(file + ".fnt");
		fontData = new Map();

		var arr = fnt.split("\n");
		for (line in arr) {
			if (line.indexOf("char") == 0) {
				var s = line.split(" ");
				var key = s[1];
				var idx = Utils.getInt(key.split("=")[1]);

				fontData[idx] = parseFontData(line);
			}
		}

		return this;
	}

	public function setWidth(w:Int):Text {
		wrapWidth = w;
		return this;
	}

	public function setHeight(h:Int):Text {
		wrapHeight = h;
		return this;
	}

	public function setLineHeight(h:Int):Text {
		lineHeight = h;
		return this;
	}

	public function center(horiz:Bool = true, vert:Bool = true):Text {
		if (horiz)
			pos_x = -textWidth * scale_x / 2;
		if (vert)
			pos_y = -textHeight * scale_y / 2;
		return this;
	}
}
