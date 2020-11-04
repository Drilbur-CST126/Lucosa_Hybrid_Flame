using Godot;
using System;
using System.Collections.Generic;

[Tool]
public class HdTileset : TileSet
{
    enum Ids
    {
        kNormal = 0,
        kWater = 1,
        kNormalBranch = 2,
    }

    private Dictionary<Ids, List<Ids>> binds = new Dictionary<Ids, List<Ids>>() {
        {Ids.kNormal, new List<Ids>{ Ids.kWater, Ids.kNormalBranch } },
        {Ids.kWater, new List<Ids>{ Ids.kNormal } }
    };

    // Called when the node enters the scene tree for the first time.
    public override bool _IsTileBound(int drawnId, int neighborId)
    {
        if(binds.ContainsKey((Ids)drawnId))
        {
            return binds[(Ids)drawnId].Contains((Ids)neighborId);
        }
        return false;
    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    //  public override void _Process(float delta)
    //  {
    //      
    //  }
}
