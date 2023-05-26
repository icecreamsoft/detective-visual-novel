package;

class Anim
{
    public static function shake(obj : GameObject, strength : Int, duration :Float) : WaitOp
    {
        var t = 0.0;
        if(duration <= 0)
        {
            return Wait.none();
        }
        var px = obj.pos_x;
        var py = obj.pos_y;

        return Wait.until(function() {
            t += GameTime.deltaTime;

            obj.pos_x = px + strength * Utils.lerp(-1, 1, Math.random());
            obj.pos_y = py + strength * Utils.lerp(-1, 1, Math.random());

            return t < duration;
        }).then(function(d) {
            obj.pos_x = px;
            obj.pos_y = py;
            return Wait.none();
        });
    }
}
