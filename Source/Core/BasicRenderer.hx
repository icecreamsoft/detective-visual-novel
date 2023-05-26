package;

import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.Image;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.utils.Float32Array;

class BasicRenderer extends GameObject {
	private var glMatrixUniform:GLUniformLocation;
	private var glTextureAttribute:Int;
	private var glVertexAttribute:Int;
	private var glColorAttribute:Int;

	private var numDraw:Int;
	private var lastTexture:Image;

	private var glProgram:GLProgram;

	private static var glProgramCache:GLProgram;

	public static var drawCallCount:Int = 0;

	public override function new(name:String, parent:GameObject = null) {
		super(name, parent);

		setupProgram();
		setupAttributes();

		addEvent("render", render);
	}

	private function setupProgram() {
		if (glProgramCache != null) {
			glProgram = glProgramCache;
			return;
		}

		var vertexSource = "attribute vec2 aPosition;
        attribute vec2 aTexCoord;
        attribute vec4 aColor;
        varying vec2 vTexCoord;
        varying vec4 vColor;

        uniform mat4 uMatrix;

        void main(void) {

            vTexCoord = aTexCoord;
            vColor = aColor;
            gl_Position = uMatrix * vec4 (aPosition, 0.0, 1.0);

        }";

		var fragmentSource = #if !desktop "precision mediump float;" + #end

		"varying vec2 vTexCoord;
        varying vec4 vColor;
        uniform sampler2D uImage0;

        void main(void)
        {
            gl_FragColor = texture2D (uImage0, vTexCoord) * vColor;
        }";

		var gl = Graphics.context.webgl;
		glProgram = GLProgram.fromSources(gl, vertexSource, fragmentSource);
		glProgramCache = glProgram;
	}

	private function setupAttributes() {
		var gl = Graphics.context.webgl;

		gl.useProgram(glProgram);
		glVertexAttribute = gl.getAttribLocation(glProgram, "aPosition");
		glTextureAttribute = gl.getAttribLocation(glProgram, "aTexCoord");
		glColorAttribute = gl.getAttribLocation(glProgram, "aColor");

		glMatrixUniform = gl.getUniformLocation(glProgram, "uMatrix");
		var imageUniform = gl.getUniformLocation(glProgram, "uImage0");

		gl.enableVertexAttribArray(glVertexAttribute);
		gl.enableVertexAttribArray(glTextureAttribute);
		gl.enableVertexAttribArray(glColorAttribute);

		gl.uniform1i(imageUniform, 0);
	}

	private function draw() {
		if (numDraw <= 0) {
			return;
		}

		var gl = Graphics.context.webgl;

		gl.bindBuffer(gl.ARRAY_BUFFER, Graphics.buffer);
		gl.bufferData(gl.ARRAY_BUFFER, Graphics.dataArray, gl.STATIC_DRAW);
		gl.vertexAttribPointer(glVertexAttribute, 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer(glColorAttribute, 4, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(glTextureAttribute, 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);

		gl.drawArrays(gl.TRIANGLES, 0, numDraw);
		numDraw = 0;

		drawCallCount++;
	}

	private function addToBuffer(v:Vector4, cx:Float, cy:Float, color:Vector4) {
		var idx = numDraw * 8;
		var bufferArray = Graphics.dataArray;
		// vertex position
		bufferArray[idx + 0] = v.x;
		bufferArray[idx + 1] = v.y;
		// color
		bufferArray[idx + 2] = color.x;
		bufferArray[idx + 3] = color.y;
		bufferArray[idx + 4] = color.z;
		bufferArray[idx + 5] = color.w;
		// texture coord
		bufferArray[idx + 6] = Math.min(1, cx);
		bufferArray[idx + 7] = Math.min(1, cy);
		++numDraw;
	}

	private function renderChildren(obj:GameObject, transform:Matrix4, color:Vector4) {
		if (obj == null || obj.visible == false || color.w <= 0) {
			return;
		}

		var gl = Graphics.context.webgl;

		var axis = new lime.math.Vector4(0, 0, 1);
		var mat = transform.clone();
		mat.prependTranslation(obj.pos_x, obj.pos_y, 0.0);
		mat.prependScale(obj.scale_x, obj.scale_y, 0.0);
		mat.prependRotation(obj.rotation, axis);

		var r = Math.max(0.0, Math.min(1.0, color.x * obj.color.x));
		var g = Math.max(0.0, Math.min(1.0, color.y * obj.color.y));
		var b = Math.max(0.0, Math.min(1.0, color.z * obj.color.z));
		var a = Math.max(0.0, Math.min(1.0, color.w * obj.color.w));
		var vcolor = new Vector4(r, g, b, a);

		if (obj.texture != null && vcolor.w > 0) {
			if (lastTexture != obj.texture) {
				draw();

				var tex = Graphics.getTexture(obj.texture);
				gl.bindTexture(gl.TEXTURE_2D, tex);

				if (obj.pixelated) {
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				} else {
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				}

				lastTexture = obj.texture;
			}

			var cx = obj.tex_coord_x;
			var cy = obj.tex_coord_y;
			var ch = obj.tex_coord_h;
			var cw = obj.tex_coord_w;

			var vec = new Vector4(0, 0);
			addToBuffer(mat.transformVector(vec), cx, cy, vcolor);

			vec.x = lastTexture.width * cw;
			vec.y = 0;
			addToBuffer(mat.transformVector(vec), cx + cw, cy, vcolor);

			vec.x = 0;
			vec.y = lastTexture.height * ch;
			addToBuffer(mat.transformVector(vec), cx, cy + ch, vcolor);

			vec.x = 0;
			vec.y = lastTexture.height * ch;
			addToBuffer(mat.transformVector(vec), cx, cy + ch, vcolor);

			vec.x = lastTexture.width * cw;
			vec.y = lastTexture.height * ch;
			addToBuffer(mat.transformVector(vec), cx + cw, cy + ch, vcolor);

			vec.x = lastTexture.width * cw;
			vec.y = 0;
			addToBuffer(mat.transformVector(vec), cx + cw, cy, vcolor);
		}

		for (c in obj.children) {
			renderChildren(c, mat, vcolor);
		}
	}

	private function render(d:DataObject):WaitOp {
		if (children.length == 0 || visible == false) {
			return null;
		}

		drawCallCount = 0;

		var gl = Graphics.context.webgl;

		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		gl.enable(gl.BLEND);

		var matrix = new Matrix4();
		matrix.createOrtho(0, Graphics.width, Graphics.height, 0, -1000, 1000);
		gl.uniformMatrix4fv(glMatrixUniform, false, matrix);

		gl.useProgram(glProgram);

		gl.activeTexture(gl.TEXTURE0);
		#if desktop
		gl.enable(gl.TEXTURE_2D);
		#end

		numDraw = 0;
		lastTexture = null;

		var white = new Vector4(1.0, 1.0, 1.0, 1.0);
		for (c in children) {
			var mat = new Matrix4();
			renderChildren(c, mat, white);
		}

		draw();

		return null;
	}
}
