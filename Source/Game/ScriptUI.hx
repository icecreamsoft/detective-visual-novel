package;

import lime.utils.Assets;

class ScriptUI extends BasicRenderer {
	var text:Text;
	var textShadow:Text;
	var textBG:GameObject;

	var credits:Text;

	var bgRoot:GameObject;
	var oldBg:GameObject;

	var portrait:GameObject;

	var transitions:Array<GameObject>;

	var TEXT_SPEED:Int = 1000;
	var pendingAction:WaitOp;

	public override function new(name:String, parent:GameObject = null) {
		super(name, parent);

		this.visible = false;

		var back = new GameObject("back", this);
		back.setTexture("img/white.png").setColor(0x131313);
		back.setScale(Game.WIDTH, Game.HEIGHT);

		oldBg = new GameObject("old.bg", this);
		bgRoot = new GameObject("bg", this);

		var textRoot = new GameObject("text.root", this);
		textBG = new GameObject("text.bg", textRoot);
		textBG.setTexture("img/ui/gradient.png").setColor(0xffffff);
		textBG.setAlpha(0.65);
		textBG.setScale(924, 1.85).translate(0, 400);

		textShadow = new Text("text", textRoot).setFont("fonts/orangekid");
		textShadow.setText("").setWidth(660).translate(152, 562);
		textShadow.setColor(0x131313);
		text = new Text("text", textRoot).setFont("fonts/orangekid");
		text.setText("").setWidth(660).translate(150, 560);

		portrait = new GameObject("char.portrait", textRoot).setAlpha(0);

		transitions = [];
		for (i in 0...16 * 12) {
			var go = new GameObject("transition." + i, this);
			go.setTexture("img/white.png").setColor(0x131313).setScale(64, 64).setAlpha(0);
			transitions.push(go);
		}

		var creditRoot = new GameObject("credits", this);
		credits = new Text("credits.text", creditRoot).setFont("fonts/sourcecodepro");

		addEvent("mouse.left.up", onMouseUp);
		addEvent(R.EV_SCRIPT_DRAW_TEXT, onDrawText);
		addEvent(R.EV_CMD_BACKGROUND, onDrawBackground);
		addEvent(R.EV_CMD_BG_MOVE, onMoveBackground);
		addEvent(R.EV_CMD_FADE_OUT, onFadeOut);
		addEvent(R.EV_CMD_FADE_IN, onFadeIn);
		addEvent(R.EV_CMD_CLEAR, onClear);
		addEvent(R.EV_CMD_WAIT, onWait);
		addEvent(R.EV_CMD_BGM, onBgm);
		addEvent(R.EV_CMD_SFX, onSfx);
		addEvent(R.EV_CMD_STOP_BGM, onStopBgm);
		addEvent(R.EV_SKIP_CHAPTER, onSkip);
		addEvent(R.EV_GAME_START, onStart);
		addEvent(R.EV_CREDITS, onCredits);
	}

	//-------------------------------------------------//
	private function onStart(data:DataObject):WaitOp {
		this.visible = true;
		return null;
	}

	private function onMouseUp(data:DataObject):WaitOp {
		if (this.visible == false)
			return null;

		if (pendingAction != null) {
			pendingAction.dispose();
		} else {
			GameEvent.send(R.EV_SCRIPT_NEXT);
		}

		return null;
	}

	private function onWait(data:DataObject):WaitOp {
		var seconds = Utils.getFloat(data.getStr("seconds", "1"));
		pendingAction = Wait.create().forSeconds(seconds);
		pendingAction.start(function() {
			pendingAction = null;
			GameEvent.send(R.EV_SCRIPT_NEXT);
		});
		return pendingAction;
	}

	private function onSkip(data:DataObject):WaitOp {
		if (pendingAction != null) {
			pendingAction.dispose();
		}
		GameEvent.send(R.EV_LOAD_NEXT);

		return null;
	}

	private function onBgm(data:DataObject):WaitOp {
		var volume = Utils.getFloat(data.getStr("volume", "1.0"));
		var file = data.getStr("file");
		var speed = Utils.getFloat(data.getStr("speed", "0.1"));

		Audio.playBGM("bgm/" + file + ".ogg", volume, speed);
		GameEvent.send(R.EV_SCRIPT_NEXT);

		return null;
	}

	private function onSfx(data:DataObject):WaitOp {
		var volume = Utils.getFloat(data.getStr("volume", "1.0"));
		var file = data.getStr("file");
		var loop = data.getStr("loop") == "true";

		Audio.playSFX("sfx/" + file + ".ogg", volume, loop);

		GameEvent.send(R.EV_SCRIPT_NEXT);

		return null;
	}

	private function onStopBgm(data:DataObject):WaitOp {
		var speed = Utils.getFloat(data.getStr("speed", "0.8"));

		pendingAction = Audio.stopBGM(speed);
		pendingAction.subscribe(function() {
			GameEvent.send(R.EV_SCRIPT_NEXT);
		});

		return pendingAction;
	}

	private function onMoveBackground(data:DataObject):WaitOp {
		var from = Utils.getInt(data.getStr("from", "0"));
		var to = Utils.getInt(data.getStr("to", "0"));
		var speed = Utils.getFloat(data.getStr("speed", "0.33"));

		var posy = from;
		var p = 0.0;
		bgRoot.setPosition(0, posy);

		pendingAction = Wait.create().forLoop(function(t:Float) {
			p = t * speed;
			p = Math.min(1.0, p);
			p = 2 * p - p * p;

			bgRoot.setPosition(0, Utils.lerp(from, to, p));
			return p < 1.0;
		}).start(function() {
			pendingAction = null;
			bgRoot.setPosition(0, to);
			GameEvent.send(R.EV_SCRIPT_NEXT);
		}).start();

		return pendingAction;
	}

	private function onDrawBackground(data:DataObject):WaitOp {
		var file = data.getStr("file");
		var speed = data.getStr("speed", "0.75");
		var posy = Utils.getInt(data.getStr("posy", "0"));
		var spd = Utils.getFloat(speed);

		oldBg.texture = bgRoot.texture;
		oldBg.setPosition(bgRoot.pos_x, bgRoot.pos_y);
		bgRoot.setTexture("img/" + file).setScale(1, 1);

		var p = 0.0;
		bgRoot.setAlpha(p);
		bgRoot.setPosition(0, posy);

		pendingAction = Wait.create().forLoop(function(t:Float) {
			p = Math.min(1, t * spd);
			bgRoot.setAlpha(p);
			return p < 1.0;
		}).start(function() {
			pendingAction = null;
			bgRoot.setAlpha(1.0);
			GameEvent.send(R.EV_SCRIPT_NEXT);
		});

		return pendingAction;
	}

	private function onClear(data:DataObject):WaitOp {
		var bg = data.getStr("bg");
		var sfx = data.getStr("sfx");
		oldBg.texture = null;

		pendingAction = Wait.create().forLoop(function(t:Float) {
			var tt = Math.min(1.0, t * 8);
			tt = 2 * tt - tt * tt;
			text.parent.setAlpha(Utils.lerp(1.0, 0.0, tt));

			if (bg == "true") {
				bgRoot.setAlpha(Utils.lerp(1.0, 0.0, tt));
			}

			return tt < 1.0;
		}).start(function() {
			pendingAction = null;
			text.parent.setAlpha(0);

			if (bg == "true") {
				bgRoot.setAlpha(0);
				bgRoot.texture = null;
			}

			if (sfx == "true") {
				Audio.stopAllSfx();
			}

			GameEvent.send(R.EV_SCRIPT_NEXT);
		});

		return pendingAction;
	}

	private function onFadeIn(data:DataObject):WaitOp {
		var style = data.getStr("style", "blocks");

		// blocks
		if (style == "blocks") {
			return onFadeBlock(-1);
		} else {
			return onFadeScreen(-1);
		}

		return pendingAction;
	}

	private function onFadeOut(data:DataObject):WaitOp {
		var style = data.getStr("style", "blocks");
		text.parent.setAlpha(0);

		// blocks
		if (style == "blocks") {
			return onFadeBlock(1);
		} else {
			return onFadeScreen(1);
		}

		return pendingAction;
	}

	private function onDrawText(data:DataObject):WaitOp {
		var line = data.getStr("line");
		var f = 0.0;
		text.parent.setAlpha(1);
		portrait.setAlpha(0);

		if (line.charAt(0) == '[') {
			line = line.substr(1);
			var arr = line.split("](");
			var speaker = arr[0];
			var dialog = arr[1];
			line = "[" + speaker + "]\n";
			if (line != null) {
				line += dialog.split("\")")[0] + "\"";
			}

			if (speaker == "Takashi") {
				portrait.setTexture("img/ui/portrait_Takashi.png");
				portrait.setAlpha(1);
				portrait.setScale(0.5, 0.5).setPosition(10, 600);
			} else if (speaker == "Emiko") {
				portrait.setTexture("img/ui/portrait_Emiko.png");
				portrait.setAlpha(1);
				portrait.setScale(0.5, 0.5).setPosition(10, 600);
			}
		}
		text.setText(line).setTextFade(0.0);
		textShadow.setText(line).setTextFade(0.0);

		pendingAction = Wait.create().forLoop(function(t:Float) {
			f = t * TEXT_SPEED;
			var percent = text.setTextFade(f);
			textShadow.setTextFade(f);
			return percent < 1.0;
		}).start(function() {
			pendingAction = null;
			text.clearTextFade();
			textShadow.clearTextFade();
		});

		return pendingAction;
	}

	private function onCredits(d:DataObject):WaitOp {
		var arr = [
			"Thank you for Playing!",
			R.CREDITS_1,
			R.CREDITS_2,
			R.CREDITS_3,
			R.CREDITS_4,
			"",
		];

		credits.parent.setPosition(512, 368).setScale(1, 1);

		var spd = 0.75;

		Wait.create()
			.forLoop(function(t) {
				credits.setWidth(800).setText(arr[0]).center();
				var p = Math.min(1, t * spd);
				var pp = 2 * p - p * p;
				var a = Utils.lerp(0, 1, pp);
				credits.setAlpha(a);
				return p < 1.0;
			})
			.forSeconds(2)
			.forLoop(function(t) {
				credits.setWidth(800).setText(arr[1]).center();
				var p = Math.min(1, t * spd);
				var pp = 2 * p - p * p;
				var a = Utils.lerp(0, 1, pp);
				credits.setAlpha(a);
				return p < 1.0;
			})
			.forSeconds(2)
			.forLoop(function(t) {
				credits.setWidth(800).setText(arr[2]).center();
				var p = Math.min(1, t * spd);
				var pp = 2 * p - p * p;
				var a = Utils.lerp(0, 1, pp);
				credits.setAlpha(a);
				return p < 1.0;
			})
			.forSeconds(2)
			.forLoop(function(t) {
				credits.setWidth(800).setText(arr[3]).center();
				var p = Math.min(1, t * spd);
				var pp = 2 * p - p * p;
				var a = Utils.lerp(0, 1, pp);
				credits.setAlpha(a);
				return p < 1.0;
			})
			.forSeconds(2)
			.forLoop(function(t) {
				credits.setWidth(800).setText(arr[4]).center();
				var p = Math.min(1, t * spd);
				var pp = 2 * p - p * p;
				var a = Utils.lerp(0, 1, pp);
				credits.setAlpha(a);
				return p < 1.0;
			})
			.forSeconds(2)
			.then(function() {
				Audio.stopBGM(0.3);
			})
			.forLoop(function(t) {
				credits.setWidth(800).setText(arr[4]).center();
				var p = Math.min(1, t * spd);
				var pp = 2 * p - p * p;
				var a = Utils.lerp(1, 0, pp);
				credits.setAlpha(a);
				return p < 1.0;
			})
			.forSeconds(2.5)
			.start(function() {
				this.visible = false;
				GameEvent.send(R.EV_MAIN_MENU);
			});

		return null;
	}

	// ------------------------ //

	private function onFadeBlock(direction:Int):WaitOp {
		var p = 0.0;
		pendingAction = Wait.create().forLoop(function(t:Float) {
			p = t * 0.7;

			for (i in 0...16) {
				for (j in 0...12) {
					var ip = t * (0.7 + i * i * 0.005 + j * j * 0.005);
					ip = Math.min(1.0, ip);
					if (direction < 0) {
						ip = 1.0 - ip;
					}

					var go = transitions[i * 12 + j];
					go.setPosition(i * 64, j * 64).setAlpha(1);
					go.setScale(64 * ip, 64 * ip);
				}
			}

			return p < 1.0;
		}).forSeconds(0.2).start(function() {
			pendingAction = null;

			for (i in 0...16) {
				for (j in 0...12) {
					var go = transitions[i * 12 + j];
					go.setScale(64, 64);
					if (direction < 0) {
						go.setAlpha(0);
					} else {
						go.setAlpha(1);
					}
				}
			}

			GameEvent.send(R.EV_SCRIPT_NEXT);
		});

		return pendingAction;
	}

	private function onFadeScreen(direction:Int):WaitOp {
		var p = 0.0;
		pendingAction = Wait.create().forLoop(function(t:Float) {
			p = t * 0.7;

			for (i in 0...16) {
				for (j in 0...12) {
					var ip = t * 0.7;
					ip = Math.min(1.0, ip);
					if (direction < 0) {
						ip = 1.0 - ip;
					}

					var go = transitions[i * 12 + j];
					go.setPosition(i * 64, j * 64);
					go.setScale(64, 64).setAlpha(ip);
				}
			}

			return p < 1.0;
		}).start(function() {
			pendingAction = null;

			for (i in 0...16) {
				for (j in 0...12) {
					var go = transitions[i * 12 + j];
					go.setScale(64, 64);
					if (direction < 0) {
						go.setAlpha(0);
					} else {
						go.setAlpha(1);
					}
				}
			}

			GameEvent.send(R.EV_SCRIPT_NEXT);
		});

		return pendingAction;
	}
}
