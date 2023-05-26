package;

class Wait
{
    private static var NextID : UInt = 0;
    private static var ops : Map<UInt, WaitOp>;

    public static function create(?name : String = "") : WaitOp
    {
        if (ops == null)
        {
            ops = new Map();
        }

        ++NextID;
        var op = new WaitOp(NextID);
        op.name = name;
        if(op.name == "")
        {
            op.name = "Wait_" + NextID;
        }
        ops[NextID] = op;

        return op;
    }

    public static function stopAll()
    {
        if(ops == null)
        {
            return;
        }

        var ks = ops.keys();
        for(k in ks)
        {
            var o = ops[k];
            o.destroy();
        }
    }

    public static function update()
    {
        if (ops == null)
        {
            return;
        }

        var ks = ops.keys();
        for(k in ks)
        {
            var o = ops[k];
            if(o != null && o.isDisposed == false)
            {
                o.update();
            }
            else
            {
                ops.remove(k);
            }
        }
    }
}
