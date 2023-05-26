package;

import lime.utils.Assets;

class MainMenuUI extends BasicRenderer {
	var root:GameObject;
	var mainMenu:GameObject;
	var gallery:GameObject;
	var credits:GameObject;

	var bgRoot:GameObject;
	var back:GameObject;
	var logo:GameObject;
	var textRoot:GameObject;
	var icon:GameObject;
	var galleryImages:Array<GameObject>;

	public override function new(name:String, parent:GameObject = null) {
		super(name, parent);
		this.visible = false;

		root = new GameObject("MainMenuUI", this);

		back = new GameObject("back", root);
		back.setTexture("img/white.png").setColor(0xfefefe);
		back.setScale(Game.WIDTH, Game.HEIGHT);
		back.setPosition(0, 0);

		// --------------- //
		// Main Menu
		// --------------- //

		mainMenu = new GameObject("mainMenu", root);
		bgRoot = new GameObject("bgRoot", mainMenu);

		for (x in 0...16) {
			for (y in 0...16) {
				var c = new GameObject(x + "." + y, bgRoot);
				c.setTexture("img/main_screen.jpeg");
				c.setTexCoord(x * 64, y * 64, 64, 64);
				c.setPosition(64 * x, 64 * y);
				c.setAlpha(0);
			}
		}

		bgRoot.setScale(1.25, 1.25).setPosition(-120, -240);

		logo = new GameObject("logo", mainMenu);
		logo.setTexture("img/enigma.png");
		logo.setScale(0.5, 0.5).setPosition(280, 120);
		logo.setAlpha(0);

		textRoot = new GameObject("textRoot", mainMenu);
		textRoot.translate(510, 400);
		textRoot.setAlpha(0);

		icon = new GameObject("icon", textRoot);
		icon.setTexture("img/ui/save_feather.png");
		icon.setScale(0.5, 0.5);
		icon.setAlpha(1);

		var menus = ["Start", "Gallery", "Credits"];
		for (i in 0...menus.length) {
			var text = new Text("text", textRoot).setFont("fonts/VT323");
			text.setColor(0x4a617a);
			text.setText(menus[i]).center();
			text.setWidth(300).translate(0, i * 65);

			var button = new Button(menus[i], textRoot);
			button.setRect(-150, -30, 300, 60);
			button.translate(0, i * 65);
			button.group = "main.menu";
			button.onEnter = function(b) {
				icon.setPosition(button.pos_x - 120, button.pos_y - 40);
			};
			button.onClick = function(b) {
				GameEvent.send(R.EV_MENU_CLICK + b.name);
			};
		}

		Wait.create().forLoop(function(t:Float) {
			if (!Input.isMouseOverButton) {
				icon.setAlpha(0);
			} else {
				icon.setAlpha(1);
			}
			return true;
		}).start();

		// -------------------------- //
		// Gallery List View
		// -------------------------- //
		gallery = new GameObject("Gallery", this);
		gallery.setAlpha(0);

		var imgArr = [
			"cafe_entrance.jpeg", "cafe.jpeg", "nightclub1.jpeg", "nightclub2.jpeg", "dress1.jpeg", "ballroom.jpeg", "dress3.jpeg", "mansion_night.jpeg",
			"office.jpg", "cafe_laptop.jpeg", "outside_lab.jpeg", "lab1.jpeg", "lab_computer.jpeg", "lab2.jpeg", "lab3.jpeg", "cell.jpeg", "scientist.jpeg",
			"corp.jpeg", "office_boss.jpeg", "courtroom.jpeg", "beach.jpeg"
		];
		galleryImages = [];

		for (i in 0...imgArr.length) {
			var imgRoot = new GameObject("img.root" + i, gallery);

			var block = new GameObject("bg", imgRoot);
			block.setTexture("img/white.png").setColor(0x4a617a);
			var x = i % 4;
			var y = Math.floor(i / 4) % 3;
			var w = 200;
			var h = 200;

			block.setScale(w, h);
			block.setPosition(x * (w + 10), y * (h + 10));

			var img = new GameObject("img", imgRoot);
			img.setTexture("img/" + imgArr[i]);
			img.setDimensions(w - 10, h - 10);
			img.setPosition(x * (w + 10) + 5, y * (h + 10) + 5);

			var button = new Button("btn", imgRoot);
			button.setRect(0, 0, w, h);
			button.setPosition(x * (w + 10), y * (h + 10));
			button.group = "gallery";
			button.onClick = function(b) {
				GameEvent.send(R.EV_MENU_CLICK + "Image", new DataObject().setStr("img", imgArr[i]));
			};

			galleryImages.push(imgRoot);
		}

		var rightArrow = new Text("rightArrow", gallery);
		rightArrow.setFont("fonts/sourcecodepro", 2);
		rightArrow.setColor(0x4a617a).setPosition(850, 300);
		rightArrow.setText(">");
		var rightArrowButton = new Button("rightArrowButton", gallery);
		rightArrowButton.setRect(0, 0, 100, 100);
		rightArrowButton.setPosition(850, 300);
		rightArrowButton.group = "gallery";
		rightArrowButton.onClick = function(b) {
			gallery.findChild("leftArrow").setAlpha(1);
			gallery.findChild("leftArrowButton").as(Button).setActive(true);
			gallery.findChild("rightArrow").setAlpha(0.25);
			gallery.findChild("rightArrowButton").as(Button).setActive(false);
			GameEvent.send(R.EV_MENU_CLICK + "GalleryList", new DataObject().setInt("page", 1));
		};

		var leftArrow = new Text("leftArrow", gallery);
		leftArrow.setFont("fonts/sourcecodepro", 2);
		leftArrow.setColor(0x4a617a).setPosition(-60, 300);
		leftArrow.setText("<");
		var leftArrowButton = new Button("leftArrowButton", gallery);
		leftArrowButton.setRect(0, 0, 100, 100);
		leftArrowButton.setPosition(-60, 300);
		leftArrowButton.group = "gallery";
		leftArrowButton.onClick = function(b) {
			gallery.findChild("leftArrow").setAlpha(0.25);
			gallery.findChild("leftArrowButton").as(Button).setActive(false);
			gallery.findChild("rightArrow").setAlpha(1);
			gallery.findChild("rightArrowButton").as(Button).setActive(true);
			GameEvent.send(R.EV_MENU_CLICK + "GalleryList", new DataObject().setInt("page", 0));
		};

		var mx = (Game.WIDTH - 200 * 4 - 10 * 3) / 2;
		var my = (Game.HEIGHT - 200 * 3 - 10 * 2) / 2;
		gallery.setPosition(mx, my);

		var backToMain = new Button("backToMain", gallery);
		backToMain.setFont("fonts/VT323").setText("<< Back");
		backToMain.setColor(0x4a617a).setPosition(800, -54);
		backToMain.setRect(0, 0, 300, 32);
		backToMain.group = "gallery";
		backToMain.onClick = function(b) {
			GameEvent.send(R.EV_MENU_CLICK + "Gallery.exit");
		}

		// -------------------------- //
		// Gallery Full View
		// -------------------------- //
		var full = new GameObject("gallery.full", gallery);
		full.setAlpha(0);

		var fullBg = new GameObject("gallery.full.bg", full);
		fullBg.setTexture("img/white.png").setColor(0xfefefe);
		fullBg.setScale(Game.WIDTH, Game.HEIGHT);
		fullBg.setPosition(-mx, -my);
		var fullImage = new GameObject("gallery.full.image", full);

		var fullButton = new Button("gallery.full.button", gallery);
		fullButton.setPosition(-mx, -my);
		fullButton.setRect(0, 0, Game.WIDTH, Game.HEIGHT);
		fullButton.group = "gallery.full";
		fullButton.onClick = function(b) {
			GameEvent.send(R.EV_MENU_CLICK + "Image.exit");
		}

		// -------------------------- //
		// Credits View
		// -------------------------- //
		credits = new GameObject("credits", root);
		credits.setAlpha(0);
		credits.addText().setFont("fonts/sourcecodepro").setColor(0x4a617a);
		credits.addButton()
			.setRect(0, 0, Game.WIDTH, Game.HEIGHT)
			.setGroup("credits")
			.setClickEvent(function(b) {
				GameEvent.send(R.EV_MENU_CLICK + "Credits.exit");
			});

		// --------------- //
		// Events
		// --------------- //

		addEvent(R.EV_MAIN_MENU, onMainMenu);
		addEvent(R.EV_MENU_CLICK + "Start", onStartGame);
		addEvent(R.EV_MENU_CLICK + "Gallery", onGallery);
		addEvent(R.EV_MENU_CLICK + "Credits", onCredits);
		addEvent(R.EV_MENU_CLICK + "Credits.exit", onCreditsExit);
		addEvent(R.EV_MENU_CLICK + "Gallery.exit", onGalleryExit);
		addEvent(R.EV_MENU_CLICK + "GalleryList", onGalleryList);
		addEvent(R.EV_MENU_CLICK + "Image", onGalleryImage);
		addEvent(R.EV_MENU_CLICK + "Image.exit", onGalleryImageExit);
	}

	//-------------------------------------------------//

	private function onMainMenu(data:DataObject):WaitOp {
		var speed = 0.65;
		this.visible = true;
		root.setAlpha(1);
		logo.setAlpha(0);
		back.setAlpha(1);
		bgRoot.setAlpha(0.6);
		textRoot.setAlpha(0);

		Audio.playBGM("bgm/Piano_Intro.ogg", 0.5, 0.2);

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1.5, t * speed);

			for (c in bgRoot.children) {
				var arr = c.name.split(".");
				var x = Utils.getInt(arr[0]);
				var y = Utils.getInt(arr[1]);
				var dx = 0 - Math.abs(x - 7.5);
				var dy = 0 - Math.abs(y - 7.5);

				var a = Utils.lerp(0, 1, p + dx * dx * dx * 0.0035 + dy * dy * dy * 0.0035);
				a = Math.min(1, a);
				c.setAlpha(a);
			}
			return p < 1.5;
		}).forSeconds(0.1).forLoop(function(t:Float) {
			var p = Math.min(1, t * speed * 1.5);
			var pp = 2 * p - p * p;

			logo.setAlpha(Utils.lerp(0, 0.9, pp));
			textRoot.setAlpha(Utils.lerp(0, 1, pp));
			return p < 1.0;
		}).start(function() {
			logo.setAlpha(0.9);
			textRoot.setAlpha(1);
			Button.activeGroup = "main.menu";
		});

		return null;
	}

	private function onStartGame(d:DataObject):WaitOp {
		var speed = 0.6;
		Audio.stopBGM(speed * 0.5);
		Audio.playSFX("sfx/menu_click.ogg");
		Button.activeGroup = "";

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			root.setAlpha(Utils.lerp(1, 0, pp));
			return p < 1.0;
		}).forSeconds(0.6).start(function() {
			GameEvent.send(R.EV_GAME_START);
			this.visible = false;
		});

		return null;
	}

	private function onCredits(d:DataObject):WaitOp {
		var speed = 1.2;
		Audio.playSFX("sfx/menu_click.ogg");
		Button.activeGroup = "";

		var t = credits.getText();
		t.setText([R.CREDITS_1, R.CREDITS_2, R.CREDITS_3, R.CREDITS_4].join("\n\n\n"));
		t.setPosition(100, 50);

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			mainMenu.setAlpha(Utils.lerp(1, 0, pp));
			return p < 1.0;
		}).forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			credits.setAlpha(Utils.lerp(0, 1, pp));
			return p < 1.0;
		}).start(function() {
			Button.activeGroup = "credits";
		});

		return null;
	}

	private function onCreditsExit(d:DataObject):WaitOp {
		var speed = 1.2;
		Audio.playSFX("sfx/menu_click.ogg");
		Button.activeGroup = "";

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			credits.setAlpha(Utils.lerp(1, 0, pp));
			return p < 1.0;
		}).forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			mainMenu.setAlpha(Utils.lerp(0, 1, pp));
			return p < 1.0;
		}).start(function() {
			Button.activeGroup = "main.menu";
		});

		return null;
	}

	private function onGallery(d:DataObject):WaitOp {
		var speed = 1.2;
		Audio.playSFX("sfx/menu_click.ogg");
		Button.activeGroup = "";

		gallery.findChild("leftArrow").setAlpha(0.25);
		gallery.findChild("leftArrowButton").as(Button).setActive(false);
		gallery.findChild("rightArrow").setAlpha(1);
		gallery.findChild("rightArrowButton").as(Button).setActive(true);

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			mainMenu.setAlpha(Utils.lerp(1, 0, pp));
			return p < 1.0;
		}).start(function() {
			Button.activeGroup = "gallery";
			GameEvent.send(R.EV_MENU_CLICK + "GalleryList", new DataObject().setInt("page", 0).setInt("silent", 1));
		});

		return null;
	}

	private function onGalleryExit(d:DataObject):WaitOp {
		var speed = 1.2;
		Audio.playSFX("sfx/menu_click.ogg");
		Button.activeGroup = "";

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			gallery.setAlpha(Utils.lerp(1, 0, pp));
			return p < 1.0;
		}).forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			mainMenu.setAlpha(Utils.lerp(0, 1, pp));
			return p < 1.0;
		}).start(function() {
			Button.activeGroup = "main.menu";
		});

		return null;
	}

	private function onGalleryList(d:DataObject):WaitOp {
		var speed = 1.2;
		var page = d.getInt("page", 0);
		if (d.getInt("silent", 0) == 0) {
			Audio.playSFX("sfx/menu_click.ogg");
		}

		Wait.create().forLoop(function(t:Float) {
			gallery.setAlpha(1);

			var delay = 0.0;
			var done = true;
			var min = page * 12;
			var max = (page + 1) * 12;

			var i = -1;
			for (c in galleryImages) {
				++i;
				var btn = c.findChild("btn").as(Button);

				if (i < min || i >= max) {
					c.setAlpha(0);
					btn.setActive(false);
					continue;
				}
				var p = (t - delay) * speed;
				p = Math.max(0, p);
				p = Math.min(1, p);
				var pp = 2 * p - p * p;

				c.setAlpha(Utils.lerp(0, 1, pp));
				delay += 0.04;
				done = (done && pp >= 1);
				btn.setActive(true);
			}

			return !done;
		}).start();

		return null;
	}

	private function onGalleryImage(d:DataObject):WaitOp {
		Audio.playSFX("sfx/click.ogg");
		var img = d.getStr("img");
		if (img == null || img == "")
			return null;

		var speed = 1.2;
		Button.activeGroup = "";

		var full = gallery.findChild("gallery.full");
		var fullImage = full.findChild("gallery.full.image");
		fullImage.setTexture("img/" + img);
		fullImage.setDimensions(768, 768);

		var cx = (Game.WIDTH - gallery.pos_x * 2) / 2 - (768 / 2);
		var cy = (Game.HEIGHT - gallery.pos_y * 2) / 2 - (768 / 2);
		fullImage.setPosition(cx, cy);

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			full.setAlpha(Utils.lerp(0, 1, pp));
			return p < 1.0;
		}).start(function() {
			Button.activeGroup = "gallery.full";
		});

		return null;
	}

	private function onGalleryImageExit(d:DataObject):WaitOp {
		Audio.playSFX("sfx/click.ogg");

		Button.activeGroup = "";
		var speed = 1.2;

		var full = gallery.findChild("gallery.full");

		Wait.create().forLoop(function(t:Float) {
			var p = Math.min(1, t * speed);
			var pp = 2 * p - p * p;

			full.setAlpha(Utils.lerp(1, 0, pp));
			return p < 1.0;
		}).start(function() {
			Button.activeGroup = "gallery";
		});

		return null;
	}

	//-------------------------------------------------//
}
