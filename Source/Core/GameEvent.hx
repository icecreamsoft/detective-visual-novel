package;

class GameEvent {
	private static var events:Map<String, GameEvent>;

	//---------------------------//
	private var listeners:List<DataObject->WaitOp>;

	private function new() {
		listeners = new List();
	}

	public function add(listener:DataObject->WaitOp) {
		listeners.add(listener);
	}

	public function remove(listener:DataObject->WaitOp) {
		listeners.remove(listener);
	}

	public function dispatch(data:DataObject):Array<WaitOp> {
		var arr = [];
		for (f in listeners) {
			arr.push(f(data));
		}

		if (data != null) {
			data.destroy();
		}
		return arr;
	}

	//---------------------------//

	public static function listen(id:String, listener:DataObject->WaitOp) {
		if (events == null) {
			events = new Map();
		}

		var ev = events[id];
		if (ev == null) {
			ev = new GameEvent();
			events[id] = ev;
		}

		ev.add(listener);
	}

	public static function unsubscribe(id:String, listener:DataObject->WaitOp) {
		if (events == null) {
			events = new Map();
		}

		var ev = events[id];
		if (ev != null) {
			ev.remove(listener);
		}
	}

	public static function send(id:String, data:DataObject = null):Array<WaitOp> {
		if (events == null) {
			events = new Map();
		}
		// if (id != "render" && id != "update")
		// 	trace("game event", id);

		var ev = events[id];
		if (ev != null) {
			return ev.dispatch(data);
		}

		return [];
	}
}
