package;

import lime.app.Application;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.RenderContext;
import lime.utils.Assets;
import lime.utils.Float32Array;

class Main extends Application {
	private var fps:Float;
	private var game:Game;

	public function new() {
		super();
	}

	public override function onKeyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		// if key is F2 key, print out the FPS info to console
		if (keyCode == lime.ui.KeyCode.F2) {
			trace("FPS:", fps, "/ DRAW CALL:", BasicRenderer.drawCallCount);
		}

		if (keyCode == lime.ui.KeyCode.ESCAPE) {
			#if !html5
			window.close();
			#end
		}

		if (keyCode == lime.ui.KeyCode.F5) {
			start();
		}

		if (keyCode == lime.ui.KeyCode.F6) {
			window.fullscreen = !window.fullscreen;
		}

		if (game == null)
			return;

		game.onKeyDown(keyCode);
	}

	public override function onMouseDown(x:Float, y:Float, button:lime.ui.MouseButton) {
		if (button == lime.ui.MouseButton.LEFT) {
			GameEvent.send("mouse.left.down");
		} else if (button == lime.ui.MouseButton.RIGHT) {
			GameEvent.send("mouse.right.down");
		}
	}

	public override function onMouseUp(x:Float, y:Float, button:lime.ui.MouseButton) {
		if (button == lime.ui.MouseButton.LEFT) {
			GameEvent.send("mouse.left.up");
		} else if (button == lime.ui.MouseButton.RIGHT) {
			GameEvent.send("mouse.right.up");
		}
	}

	public override function onMouseMove(x:Float, y:Float) {
		var sx = Game.WIDTH / window.width;
		var sy = Game.HEIGHT / window.height;

		var winRatio = window.width / window.height;
		var gameRatio = Game.WIDTH / Game.HEIGHT;

		if (gameRatio > winRatio) {
			// black bars on top / bottom
			var viewportHeight = Game.HEIGHT / sx;
			var adjustY = (window.height - viewportHeight) / 2;
			y -= adjustY;
			sy = Game.HEIGHT / viewportHeight;
		} else if (gameRatio < winRatio) {
			// black bars on left / right
			var viewportWidth = Game.WIDTH / sy;
			var adjustX = (window.width - viewportWidth) / 2;
			x -= adjustX;
			sx = Game.WIDTH / viewportWidth;
		}

		Input.mouse.x = x * sx;
		Input.mouse.y = y * sy;
	}

	public override function update(deltaTime:Int):Void {
		GameTime.deltaTime = deltaTime * GameTime.timeScale / 1000;

		// calculate FPS by dividing 1 second by deltaTime (deltaTime is in milliseconds)
		fps = 1000 / deltaTime;
		++GameTime.frameCount;

		Input.isMouseOverButton = false;
		GameEvent.send("update");
		Wait.update();

		if (Input.isMouseOverButton) {
			window.cursor = lime.ui.MouseCursor.POINTER;
		} else {
			window.cursor = lime.ui.MouseCursor.DEFAULT;
		}
	}

	private function start() {
		if (game != null) {
			Wait.stopAll();
			game.destroy();
		}
		Wait.create();
		game = new Game("game");
	}

	public override function render(context:RenderContext):Void {
		if (!preloader.complete) {
			return;
		}

		switch (context.type) {
			case OPENGL, OPENGLES, WEBGL:
				var gl = context.webgl;

				if (Graphics.context == null) {
					Graphics.context = context;
					Graphics.buffer = gl.createBuffer();
					Graphics.dataArray = new Float32Array(Game.GRAPHICS_BUFFER_SIZE * 64);
					Graphics.width = Game.WIDTH;
					Graphics.height = Game.HEIGHT;

					start();
				}

				var ratio = window.width / window.height;

				if (ratio > Graphics.width / Graphics.height) {
					var vw = Math.floor(window.height * Graphics.width / Graphics.height);
					var ox = Math.floor((window.width - vw) / 2);
					gl.viewport(ox, 0, vw, window.height);
				} else {
					var vh = Math.floor(window.width * Graphics.height / Graphics.width);
					var oy = Math.floor((window.height - vh) / 2);
					gl.viewport(0, oy, window.width, vh);
				}

				var r = ((context.attributes.background >> 16) & 0xFF) / 0xFF;
				var g = ((context.attributes.background >> 8) & 0xFF) / 0xFF;
				var b = (context.attributes.background & 0xFF) / 0xFF;
				var a = ((context.attributes.background >> 24) & 0xFF) / 0xFF;

				gl.clearColor(r, g, b, a);
				gl.clear(gl.COLOR_BUFFER_BIT);

				GameEvent.send("render");

			default:
		}
	}
}
