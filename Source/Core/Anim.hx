package;

class Anim {
	public static function shake(obj:GameObject, strength:Int, duration:Float):WaitOp {
		var t = 0.0;
		if (duration <= 0) {
			return Wait.create().start();
		}
		var px = obj.pos_x;
		var py = obj.pos_y;

		return Wait.create().forLoop(function(t) {
			obj.pos_x = px + strength * Utils.lerp(-1, 1, Math.random());
			obj.pos_y = py + strength * Utils.lerp(-1, 1, Math.random());

			return t < duration;
		}).start(function() {
			obj.pos_x = px;
			obj.pos_y = py;
		});
	}
}
