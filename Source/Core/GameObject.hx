package;

import lime.graphics.Image;
import lime.utils.Assets;
import lime.math.Vector4;
import lime.math.Matrix4;
import lime.app.Promise;

class GameObject {
	public var name:String;
	public var parent(default, set):GameObject;
	public var children(default, null):List<GameObject>;

	public var visible:Bool = true;

	public var pos_x:Float = 0.0;
	public var pos_y:Float = 0.0;
	public var rotation:Float = 0.0;
	public var scale_x:Float = 1.0;
	public var scale_y:Float = 1.0;

	public var color:Vector4 = new Vector4(1, 1, 1, 1);

	public var texture:Image = null;

	public var tex_coord_x:Float = 0.0;
	public var tex_coord_y:Float = 0.0;
	public var tex_coord_w:Float = 1.0;
	public var tex_coord_h:Float = 1.0;

	public var pixelated:Bool = true;

	private var eventListeners:Map<String, DataObject->WaitOp>;

	public function new(objName:String, parentObj:GameObject = null) {
		name = objName;
		children = new List();
		eventListeners = new Map();
		parent = parentObj;
	}

	public function destroy() {
		parent = null;

		for (c in children) {
			c.destroy();
		}

		for (k in eventListeners.keys()) {
			GameEvent.unsubscribe(k, eventListeners[k]);
		}

		name = null;
		children = null;
		eventListeners = null;
		texture = null;
		color = null;
	}

	private function addEvent(key:String, handler:DataObject->WaitOp) {
		eventListeners[key] = handler;
		GameEvent.listen(key, handler);
	}

	private function set_parent(t:GameObject) {
		if (this.parent == t) {
			return this.parent;
		}

		// remove child from old parent
		if (this.parent != null) {
			this.parent.children.remove(this);
		}

		// set parent to new parent
		this.parent = t;
		if (this.parent != null) {
			this.parent.children.add(this);
		}

		return this.parent;
	}

	@:generic public function as<T:GameObject>(cls:Class<T>):T {
		return Std.downcast(this, cls);
	}

	public function addText():Text {
		return getText();
	}

	public function addButton():Button {
		return getButton();
	}

	public function getText():Text {
		var t = findChild(name + ".txt");
		if (t != null) {
			return t.as(Text);
		}

		var txt = new Text(name + ".txt", this);
		return txt;
	}

	public function getButton():Button {
		var b = findChild(name + ".btn");
		if (b != null) {
			return b.as(Button);
		}

		var btn = new Button(name + ".btn", this);
		return btn;
	}

	public function findChild(name:String) {
		for (c in children) {
			if (c.name == name) {
				return c;
			}
		}

		return null;
	}

	public function setVisible(v:Bool) {
		visible = v;
		return this;
	}

	public function setPosition(x:Float, y:Float) {
		pos_x = x;
		pos_y = y;
		return this;
	}

	public function translate(x:Float, y:Float) {
		pos_x += x;
		pos_y += y;
		return this;
	}

	public function setScale(sx:Float, sy:Float) {
		scale_x = sx;
		scale_y = sy;
		return this;
	}

	public function setDimensions(sx:Int, sy:Int) {
		if (texture != null) {
			scale_x = sx / texture.width;
			scale_y = sy / texture.height;
		}
		return this;
	}

	public function setRotation(rot:Float) {
		rotation = rot;
		return this;
	}

	public function rotate(rot:Float) {
		rotation += rot;
		return this;
	}

	public function setTexture(file:String, isPixelGraphics:Bool = true) {
		var img = Assets.getImage(file);
		if (img != null) {
			texture = img;
		}

		pixelated = isPixelGraphics;

		return this;
	}

	public function setTexCoord(cx:Float, cy:Float, cw:Float, ch:Float) {
		if (texture != null) {
			tex_coord_x = cx / texture.width;
			tex_coord_y = cy / texture.height;
			tex_coord_w = cw / texture.width;
			tex_coord_h = ch / texture.height;
		}

		return this;
	}

	public function setAlpha(a:Float) {
		a = Math.max(0.0, Math.min(1.0, a));
		color.w = a;
		return this;
	}

	public function setColor(col:Int) {
		var r = (col >> 16) & 0xFF;
		var g = (col >> 8) & 0xFF;
		var b = col & 0xFF;

		color.x = (r / 0xFF);
		color.y = (g / 0xFF);
		color.z = (b / 0xFF);

		return this;
	}

	public function getChild(name:String) {
		for (c in children) {
			if (c.name == name) {
				return c;
			}
		}

		return null;
	}

	public function centerImage() {
		if (texture != null) {
			pos_x = -tex_coord_w * texture.width * scale_x / 2;
			pos_y = -tex_coord_h * texture.height * scale_y / 2;
		}
		return this;
	}

	private function calculateTransform():Matrix4 {
		var p = this;
		var list = new List<GameObject>();
		while (p != null) {
			list.push(p);
			p = p.parent;
		}

		var axis = new Vector4(0, 0, 1);
		var mat = new Matrix4();
		for (go in list) {
			mat.prependTranslation(go.pos_x, go.pos_y, 0.0);
			mat.prependScale(go.scale_x, go.scale_y, 0.0);
			mat.prependRotation(go.rotation, axis);
		}
		return mat;
	}

	private function calculateTransformInvert():Matrix4 {
		var p = this;
		var list = new List<GameObject>();
		while (p != null) {
			list.push(p);
			p = p.parent;
		}

		var axis = new Vector4(0, 0, 1);
		var mat = new Matrix4();
		for (go in list) {
			mat.appendTranslation(-go.pos_x, -go.pos_y, 0.0);
			mat.appendScale(1.0 / go.scale_x, 1.0 / go.scale_y, 0.0);
			mat.appendRotation(-go.rotation, axis);
		}
		return mat;
	}
}
