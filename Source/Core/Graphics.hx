
package;

import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;

import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.graphics.Image;

import lime.utils.Assets;

class Graphics {

    public static var context : RenderContext;
    public static var buffer : GLBuffer;
    public static var dataArray : Float32Array;

    public static var width : Int;
    public static var height : Int;

    public static var textureCache : Map<Image,GLTexture>;

    public static function getTexture(image : Image)
    {
        if(textureCache == null)
        {
            textureCache = new Map();
        }

        if(textureCache[image] != null)
        {
            return textureCache[image];
        }

        var gl = context.webgl;
        var tex = gl.createTexture();

        gl.bindTexture (gl.TEXTURE_2D, tex);
        gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        #if js
        gl.texImage2D (gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image.src);
        #else
        gl.texImage2D (gl.TEXTURE_2D, 0, gl.RGBA, image.buffer.width, image.buffer.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
        #end

        gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.bindTexture (gl.TEXTURE_2D, null);

        textureCache[image] = tex;
        return tex;
    }

    public static function reset()
    {
        var gl = context.webgl;

        for(t in textureCache)
        {
            gl.deleteTexture(t);
        }
        textureCache = new Map();
    }

}
