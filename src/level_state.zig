const Level = @import("level.zig").Level;
const LevelKey = @import("level.zig").LevelKey;
const ThingPool = @import("things.zig").ThingPool;

// just throwing ideas around. need to think carefully about stack etc.
// tbh thingpool and level data (map etc) should probs be on the heap.
const LevelState = struct {
    level: Level,
    key: LevelKey,
    things: ThingPool,
};
