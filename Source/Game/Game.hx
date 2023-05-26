package;

@:expose
class Game extends GameObject {
	public static inline var WIDTH = 1024;
	public static inline var HEIGHT = 768;
	public static inline var GRAPHICS_BUFFER_SIZE = 1024 * 8;
	public static var activeGame:Game;

	var script:ScriptSystem;
	var scriptUI:ScriptUI;
	var main:MainMenuUI;

	public function new(name:String) {
		super(name, null);
		Game.activeGame = this;

		script = new ScriptSystem("script", this);
		scriptUI = new ScriptUI("script.ui", this);
		main = new MainMenuUI("main", this);

		GameEvent.send(R.EV_MAIN_MENU);
	}

	public function onKeyDown(keyCode:lime.ui.KeyCode) {
		if (!scriptUI.visible) {
			return;
		}

		if (keyCode == lime.ui.KeyCode.NUMBER_1) {
			GameEvent.send(R.EV_SKIP_CHAPTER);
		} else if (keyCode == lime.ui.KeyCode.RETURN) {
			GameEvent.send("mouse.left.up");
		}
	}
}
