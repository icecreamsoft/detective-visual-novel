package;

class DataObject {
	private var mapInt:Map<String, Int>;
	private var mapStr:Map<String, String>;
	private var mapFloat:Map<String, Float>;
	private var mapData:Map<String, DataObject>;

	public function new() {}

	public function destroy() {
		mapInt = null;
		mapStr = null;
		mapFloat = null;

		if (mapData != null) {
			for (d in mapData) {
				d.destroy();
			}
		}
		mapData = null;
	}

	public function clone():DataObject {
		var d = new DataObject();

		if (mapInt != null) {
			for (k in mapInt.keys()) {
				d.setInt(k, mapInt[k]);
			}
		}

		if (mapStr != null) {
			for (k in mapStr.keys()) {
				d.setStr(k, mapStr[k]);
			}
		}

		if (mapFloat != null) {
			for (k in mapFloat.keys()) {
				d.setFloat(k, mapFloat[k]);
			}
		}

		return d;
	}

	public function getStr(key:String, def:String = ""):String {
		if (mapStr != null) {
			return mapStr[key] != null ? mapStr[key] : def;
		}

		return def;
	}

	public function setStr(key:String, val:String) {
		if (mapStr == null) {
			mapStr = new Map();
		}

		mapStr[key] = val;
		return this;
	}

	public function getInt(key:String, def:Int = 0):Int {
		if (mapInt != null) {
			return mapInt[key] != null ? mapInt[key] : def;
		}

		return def;
	}

	public function addInt(key:String, delta:Int) {
		if (mapInt != null) {
			mapInt[key] = mapInt[key] + delta;
		}
	}

	public function setInt(key:String, val:Int) {
		if (mapInt == null) {
			mapInt = new Map();
		}

		mapInt[key] = val;
		return this;
	}

	public function getFloat(key:String, def:Float = 0.0):Float {
		if (mapFloat != null) {
			return mapFloat[key] != null ? mapFloat[key] : def;
		}

		return def;
	}

	public function addFloat(key:String, delta:Float) {
		if (mapFloat != null) {
			mapFloat[key] = mapFloat[key] + delta;
		}
	}

	public function setFloat(key:String, val:Float) {
		if (mapFloat == null) {
			mapFloat = new Map();
		}

		mapFloat[key] = val;
		return this;
	}

	public function getData(key:String):DataObject {
		if (mapData != null) {
			return mapData[key];
		}

		return null;
	}

	public function setData(key:String, val:DataObject) {
		if (mapData == null) {
			mapData = new Map();
		}

		mapData[key] = val;
		return this;
	}
}
