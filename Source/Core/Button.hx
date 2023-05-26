package;

import lime.math.Rectangle;
import lime.math.Vector4;

class Button extends Text {
	public var rect(default, null):Rectangle;
	public var isMouseOver(default, null):Bool = false;
	public var isActive:Bool = true;

	public var onClick:Button->Void;
	public var onEnter:Button->Void;
	public var onExit:Button->Void;

	public var group:String = "";

	public static var activeGroup:String = "";
	private static var lastButtonDown:Button;

	public override function new(name:String, parent:GameObject) {
		super(name, parent);

		rect = new Rectangle(0, 0, 0, 0);

		addEvent("update", onUpdate);
		addEvent("mouse.left.up", onMouseUp);
		addEvent("mouse.left.down", onMouseDown);
	}

	public override function destroy() {
		super.destroy();
		rect = null;
		onClick = null;
		onEnter = null;
		onExit = null;
	}

	public function setClickEvent(ev:Button->Void) {
		onClick = ev;
		return this;
	}

	public function setGroup(g:String) {
		group = g;
		return this;
	}

	public function setRect(x:Int, y:Int, w:Int, h:Int):Button {
		rect.x = x;
		rect.y = y;
		rect.width = w;
		rect.height = h;
		return this;
	}

	public function setRectFromImage():Button {
		rect.x = rect.y = 0;
		rect.width = tex_coord_w * texture.width;
		rect.height = tex_coord_h * texture.height;

		return this;
	}

	public function setActive(active:Bool):Button {
		isActive = active;
		return this;
	}

	private function onMouseDown(d:DataObject):WaitOp {
		if (isActive == false || Button.activeGroup != group) {
			return null;
		}

		if (isMouseOver) {
			Button.lastButtonDown = this;
		}
		return null;
	}

	private function onMouseUp(d:DataObject):WaitOp {
		if (isActive == false || Button.activeGroup != group) {
			return null;
		}

		if (isMouseOver && Button.lastButtonDown == this && onClick != null) {
			onClick(this);
			Button.lastButtonDown = null;
		}
		return null;
	}

	private function onUpdate(d:DataObject):WaitOp {
		if (isActive == false || Button.activeGroup != group) {
			return null;
		}

		var mat = calculateTransformInvert();
		var vec = new Vector4(Input.mouse.x, Input.mouse.y);
		vec = mat.transformVector(vec);

		var over = rect.contains(vec.x, vec.y);
		if (isMouseOver != over && over && onEnter != null) {
			onEnter(this);
		} else if (isMouseOver != over && !over && onExit != null) {
			onExit(this);
		}

		isMouseOver = over;
		if (isMouseOver) {
			Input.isMouseOverButton = isMouseOver;
		}

		return null;
	}
}
