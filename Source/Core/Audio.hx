package;

import lime.utils.Assets;
import lime.media.AudioSource;

class Audio {
	private inline static var BGM_SCALE:Float = 0.7;
	private inline static var SFX_SCALE:Float = 0.5;

	public static var BGM_VOLUME:Float = 1.0;
	public static var SFX_VOLUME:Float = 1.0;

	public static var currentBGM:AudioSource;

	private static var bgmTable:Map<String, AudioSource>;
	private static var soundTable:Map<Int, AudioSource>;

	private static var dispFadeBGM:WaitOp;
	private static var SFX_ID:Int = 0;

	private static function getSfx(file:String, id:Int):AudioSource {
		if (soundTable == null) {
			soundTable = new Map();
		}

		var buffer = Assets.getAudioBuffer(file);
		var src = new AudioSource(buffer);
		soundTable[id] = src;

		return src;
	}

	private static function getBgm(file:String):AudioSource {
		if (bgmTable == null) {
			bgmTable = new Map();
		}

		var src = bgmTable[file];
		if (src == null) {
			var buffer = Assets.getAudioBuffer(file);
			src = new AudioSource(buffer);
			bgmTable[file] = src;
		}

		return src;
	}

	public static function stopAllSfx() {
		if (soundTable == null)
			return;

		for (src in soundTable) {
			if (src != null) {
				src.stop();
				src.dispose();
			}
		}

		soundTable = new Map();
	}

	public static function playBGM(file:String, volume:Float = 1.0, fade:Float = 0.2) {
		var info = [];
		if (file != null) {
			info = file.split(",");
		}
		var src = getBgm(info[0]);

		if (currentBGM != null) {
			currentBGM.stop();
			if (dispFadeBGM != null) {
				dispFadeBGM.dispose();
				dispFadeBGM = null;
			}
		}

		if (src != null) {
			var fVolume = volume * Utils.getFloat(info[1], 1.0);
			src.gain = fVolume * BGM_VOLUME * BGM_SCALE;
			src.loops = (1 << 26);
			src.play();
			if (fade > 0) {
				src.gain = 0;
				dispFadeBGM = fadeVolume(src, 0.0, fVolume, fade);
			}
		}

		currentBGM = src;
		return src;
	}

	public static function stopBGM(speed:Float = 0.8) {
		var src = currentBGM;
		if (src == null)
			return Wait.create().start();

		var from = src.gain;
		var to = 0.0;

		return Wait.create().forLoop(function(t) {
			t = Math.min(t * speed, 1);
			var tt = 2 * t - t * t;
			var vol = Utils.lerp(from, to, tt);
			src.gain = vol;
			return t < 1;
		}).start();
	}

	public static function playSFX(file:String, volume:Float = 1.0, loop:Bool = false):AudioSource {
		var info = [];
		if (file != null) {
			info = file.split(",");
		}

		var id = ++SFX_ID;
		var src = getSfx(info[0], id);

		if (src != null) {
			src.gain = volume * SFX_VOLUME * SFX_SCALE * Utils.getFloat(info[1], 1.0);
			if (!loop) {
				src.onComplete.add(function() {
					src.dispose();
					if (src == soundTable[id]) {
						soundTable.remove(id);
					}
				});
			} else {
				src.loops = (1 << 26);
			}
			src.play();
		}

		return src;
	}

	public static function fadeVolume(src:AudioSource, from:Float, to:Float, speed:Float):WaitOp {
		return Wait.create("update").forLoop(function(t) {
			t = Math.min(t * speed, 1);
			var tt = 2 * t - t * t;
			var vol = Utils.lerp(from, to, tt);

			var scale = SFX_VOLUME * SFX_SCALE;
			if (src.loops > 0) {
				scale = BGM_VOLUME * BGM_SCALE;
			}
			src.gain = vol * scale;

			return t < 1;
		}).start();
	}

	public static function playRandomSFX(csv:String) {
		var files = csv.split(",");
		var idx = Utils.rollDice(files.length);
		playSFX(files[idx]);
	}
}
