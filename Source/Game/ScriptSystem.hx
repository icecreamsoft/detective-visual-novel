package;

import lime.utils.Assets;

class ScriptSystem extends GameObject {
	private var scriptLines:Array<String>;
	private var currentLine:Int = 0;
	private var currentFile:String = "chapter1.md";

	public override function new(name:String, parent:GameObject = null) {
		super(name, parent);

		addEvent(R.EV_GAME_START, onStart);
		addEvent(R.EV_CMD_LOAD, onLoad);
		addEvent(R.EV_SCRIPT_NEXT, onScriptNextLine);
		addEvent(R.EV_LOAD_NEXT, onNextChapter);
	}

	//-------------------------------------------------//

	private function onStart(data:DataObject):WaitOp {
		scriptLines = Utils.readTxtFile("txt/chapter1.md");
		currentLine = -1;
		GameEvent.send(R.EV_SCRIPT_NEXT);
		return null;
	}

	private function onNextChapter(data:DataObject):WaitOp {
		var file = "";

		switch (currentFile) {
			case "chapter1.md":
				file = "chapter2.md";
			case "chapter2.md":
				file = "chapter3.md";
			case "chapter3.md":
				file = "chapter4.md";
			case "chapter4.md":
				file = "chapter5.md";
			case "chapter5.md":
				file = "chapter6.md";
			default:
				file = "";
		}

		if (file == "") {
			return null;
		}

		currentFile = file;
		scriptLines = Utils.readTxtFile("txt/" + file);
		currentLine = -1;
		GameEvent.send(R.EV_SCRIPT_NEXT);
		return null;
	}

	private function onLoad(data:DataObject):WaitOp {
		var file = data.getStr("file");

		currentFile = file;
		scriptLines = Utils.readTxtFile("txt/" + file);
		currentLine = -1;
		GameEvent.send(R.EV_SCRIPT_NEXT);
		return null;
	}

	private function onScriptNextLine(data:DataObject):WaitOp {
		if (scriptLines == null)
			return null;

		++currentLine;
		if (currentLine >= scriptLines.length) {
			return null;
		}

		var line = scriptLines[currentLine];
		if (line == null || line.length == 0) {
			GameEvent.send(R.EV_SCRIPT_NEXT);
			return null;
		}

		var d = parseCommand(line);

		return Wait.create().forAll(function() {
			return GameEvent.send(d.getStr("cmd"), d);
		}).start();
	}

	//-------------------------------------------------//

	private function parseCommand(line:String):DataObject {
		var d = new DataObject().setStr("line", line);
		var cmd = R.EV_SCRIPT_DRAW_TEXT;

		if (line.substr(0, 2) == "# ") {
			var arr = line.split(" ");
			cmd = arr[1];
			arr.shift();
			arr.shift();

			for (p in arr) {
				var parr = p.split("=");
				var k = parr[0];
				var v = parr[1];
				d.setStr(k, v);
			}
		}

		d.setStr("cmd", cmd);
		return d;
	}

	private function isGameOver():Bool {
		return false;
	}
}
