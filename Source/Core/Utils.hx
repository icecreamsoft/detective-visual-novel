package;

import lime.utils.Assets;

class Utils {
	public static function lerp(v0:Float, v1:Float, t:Float):Float {
		return (1 - t) * v0 + t * v1;
	}

	public static function lerpInt(v0:Int, v1:Int, t:Float):Int {
		return Math.round((1 - t) * v0 + t * v1);
	}

	public static function getInt(val:Dynamic, def:Int = 0):Int {
		if (val != null) {
			var n = Std.parseInt(val + "");
			if (!Math.isNaN(n) && n != null)
				return n;
		}

		return def;
	}

	public static function getFloat(val:Dynamic, def:Float = 0.0):Float {
		if (val != null) {
			var n = Std.parseFloat(val + "");
			if (!Math.isNaN(n))
				return n;
		}

		return def;
	}

	public static function getString(val:Dynamic, def:String = null):String {
		if (val != null) {
			var n = Std.downcast(val, String);
			if (n != null)
				return n;
		}

		return def;
	}

	public static function max(a:Int, b:Int):Int {
		return (a > b) ? a : b;
	}

	public static function min(a:Int, b:Int):Int {
		return (a < b) ? a : b;
	}

	public static function rollDice(sides:Int):Int {
		return Math.floor(Math.random() * sides * 100) % sides;
	}

	public static function trim(s:String):String {
		return StringTools.ltrim(StringTools.rtrim(s));
	}

	public static function readTxtFile(file:String):Array<String> {
		var str = Assets.getText(file);
		if (str == null) {
			return null;
		}

		var arr = str.split("\n");
		return arr;
	}

	public static function readDataFile(file:String):Array<DataObject> {
		var str = Assets.getText(file);
		if (str == null) {
			return null;
		}

		var arr = [];
		var objs = str.split(";;;");
		var keys = null;

		for (s in objs) {
			var lines = s.split("\n");
			var d = null;

			for (oneLine in lines) {
				var kv = oneLine.split("=");
				if (kv.length != 2)
					continue;

				var key = Utils.trim(kv[0]);
				var val = Utils.trim(kv[1]);

				if (d == null) {
					d = new DataObject();
				}

				var k = key.split(".");
				if (k[1] == "Int") {
					d.setInt(k[0], Utils.getInt(val));
				} else if (k[1] == "Float") {
					d.setFloat(k[0], Utils.getFloat(val));
				} else {
					d.setStr(k[0], val);
				}
			}

			if (d != null) {
				arr.push(d);
			}
		}

		return arr;
	}
}
