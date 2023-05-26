package;

typedef VoidFunc = Void->Void;
typedef LoopFunc = Float->Bool;
typedef WaitOpArrayFunc = Void->Array<WaitOp>;
typedef WaitOpFunc = Void->WaitOp;

class WaitOp {
	public var isDisposed:Bool = false;
	public var isCompleted:Bool = false;
	public var isStart:Bool = false;

	public var name:String = "";

	private var queue:Array<VoidFunc>;
	private var index:Int;
	private var subscribers:Array<VoidFunc>;
	private var procId:UInt = 0;
	private var opsArray:Array<WaitOp>;
	private var waitDelay:Float = 0;

	public function new(id:UInt) {
		procId = id;
		queue = [];
		subscribers = [];
		isStart = false;
		isDisposed = false;
		isCompleted = false;
	}

	public function destroy() {
		subscribers = null;
		dispose();
	}

	public function dispose() {
		if (isDisposed == false) {
			onComplete();
		}
	}

	private function _finish() {
		++index;
	}

	public function then(f:VoidFunc):WaitOp {
		var a = function() {
			f();
			_finish();
		};

		queue.push(a);
		return this;
	}

	public function forLoop(f:LoopFunc):WaitOp {
		var t:Float = 0;
		var a = function() {
			if (!f(t)) {
				_finish();
			}
			t += GameTime.deltaTime;
		};

		queue.push(a);
		return this;
	}

	public function forSeconds(t:Float):WaitOp {
		var wait = t;
		var a = function() {
			if (wait > 0) {
				wait -= GameTime.deltaTime;
			} else {
				_finish();
			}
		};

		queue.push(a);
		return this;
	}

	public function forAny(f:WaitOpArrayFunc):WaitOp {
		var initOps = false;
		var a = function() {
			if (initOps == false && f != null) {
				initOps = true;
				opsArray = f();
			}

			var anycomplete = false;

			if (opsArray != null) {
				for (i in opsArray) {
					if (i != null && i.isStart == false)
						i.start();

					if (i != null && i.isDisposed) {
						anycomplete = true;
						break;
					}
				}
			} else {
				anycomplete = true;
			}

			if (anycomplete) {
				for (i in opsArray) {
					if (i != null) {
						i.dispose();
					}
				}
				opsArray = null;
				_finish();
			}
		};

		queue.push(a);
		return this;
	}

	public function forAll(f:WaitOpArrayFunc):WaitOp {
		var initOps = false;
		var a = function() {
			if (initOps == false && f != null) {
				initOps = true;
				opsArray = f();
			}

			var allcomplete = true;

			if (opsArray != null) {
				for (i in opsArray) {
					if (i != null && i.isStart == false) {
						i.start();
					}

					if (i != null && !i.isDisposed) {
						allcomplete = false;
					}
				}
			}

			if (allcomplete) {
				opsArray = null;
				_finish();
			}
		};

		queue.push(a);
		return this;
	}

	public function forSequence(f:WaitOpArrayFunc):WaitOp {
		var initOps = false;
		var i = 0;

		var a = function() {
			if (initOps == false && f != null) {
				initOps = true;
				opsArray = f();
			}

			if (opsArray != null) {
				var oneOp = opsArray[i];
				if (oneOp != null && oneOp.isStart == false) {
					oneOp.start();
				}

				if (oneOp != null && !oneOp.isDisposed) {
					++i;
				}

				if (i >= opsArray.length) {
					opsArray = null;
					_finish();
				}
			} else {
				_finish();
			}
		};

		queue.push(a);
		return this;
	}

	public function delay(t:Float) {
		waitDelay = t;
		return this;
	}

	public function start(?f:VoidFunc):WaitOp {
		if (isStart) {
			return subscribe(f);
		}

		isStart = true;
		index = 0;
		if (f != null) {
			subscribers.push(f);
		}

		return this;
	}

	public function subscribe(?f:VoidFunc):WaitOp {
		if (!isStart) {
			return start(f);
		}

		if (isDisposed) {
			if (f != null) {
				f();
			}
			return null;
		}

		if (f != null) {
			subscribers.push(f);
		}

		return this;
	}

	public function onComplete() {
		if (!isDisposed) {
			isDisposed = true;
			queue = [];
			index = 0;

			if (opsArray != null) {
				for (i in opsArray) {
					if (i != null) {
						i.dispose();
					}
				}

				opsArray = null;
			}

			if (subscribers != null) {
				for (s in subscribers) {
					s();
				}
			}
		}
	}

	public function update() {
		if (isStart && !isDisposed && index < queue.length) {
			if (waitDelay > 0) {
				waitDelay -= GameTime.deltaTime;
			} else {
				queue[index]();
			}
		} else if (isStart && isCompleted == false) {
			isCompleted = true;
			dispose();
		}
	}
}
