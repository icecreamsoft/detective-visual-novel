
package;

import lime.graphics.Image;
import lime.utils.Assets;
import lime.math.Rectangle;

class Spritesheet {

    private var table : Map<String,Rectangle>;

    public function new(file : String)
    {
        var sheet = Assets.getText(file + ".txt");
        table = new Map();

        var lines = sheet.split("\n");
        var key = "";
        var rect = new Rectangle();
        for(oneLine in lines)
        {
            if(oneLine.indexOf(".sprite-") == 0)
            {
                key = oneLine.split(" ")[0].substring(".sprite-".length);
            }
            else if(oneLine.indexOf("width: ") >= 0)
            {
                var val = oneLine.split("width: ")[1].split("px;")[0];
                rect.width = Utils.getInt(val);
            }
            else if(oneLine.indexOf("height: ") >= 0)
            {
                var val = oneLine.split("height: ")[1].split("px;")[0];
                rect.height = Utils.getInt(val);
            }
            else if(oneLine.indexOf("-position: ") >= 0)
            {
                var val = oneLine.split("-position: ")[1].split("px");
                rect.x = -Utils.getInt(val[0]);
                rect.y = -Utils.getInt(val[1]);

                table[key] = rect.clone();
            }
        }
    }

    public function get(key : String) : Rectangle
    {
        return table[key];
    }

    public function destroy()
    {
        table = null;
    }
}
