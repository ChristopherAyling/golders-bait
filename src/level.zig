const std = @import("std");
const assert = std.debug.assert;
const Image = @import("image.zig").Image;

pub const LevelKey = enum {
    arch,
    library_gate,
    court_of_air,
    // TODO add display strings

    // todo maybe genericise this logic for all enums
    pub fn inc(self: LevelKey) LevelKey {
        const fields = std.meta.fields(LevelKey);
        const val = @intFromEnum(self);
        if (val >= fields.len - 1) return self;
        return @enumFromInt(val + 1);
    }

    pub fn dec(self: LevelKey) LevelKey {
        const val = @intFromEnum(self);
        if (val <= 0) return self;
        return @enumFromInt(val - 1);
    }
};

pub const Level = struct {
    key: LevelKey,
    bg: Image,
    fg: Image,
};
