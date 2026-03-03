// this module is like io_native but everything must be embedded into the file using @embedFile or something
// will be used by wasm etc where no io with a filesystem is possible.

const std = @import("std");
const Image = @import("image.zig").Image;
const Level = @import("level.zig").Level;
const sprites = @import("sprites.zig");
const SpriteKey = sprites.SpriteKey;
const SpriteStorage = sprites.SpriteStorage;

pub fn load_sprites(storage: *SpriteStorage) void {
    _ = storage;
}

pub fn load_level(name: []const u8) Level {
    _ = name;
    return undefined;
}
