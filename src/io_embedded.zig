// this module is like io_native but everything must be embedded into the file using @embedFile or something
// will be used by wasm etc where no io with a filesystem is possible.

const std = @import("std");
const Image = @import("image.zig").Image;
const Level = @import("level.zig").Level;
const LevelKey = @import("level.zig").LevelKey;
const sprites = @import("sprites.zig");
const SpriteKey = sprites.SpriteKey;
const SpriteStorage = sprites.SpriteStorage;
const ThingPool = @import("things.zig").ThingPool;

const stbi = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", "1");
    @cDefine("STBI_NO_GIF", "1");
    @cDefine("STBI_NO_HDR", "1");
    @cDefine("STBI_NO_TGA", "1");
    @cDefine("STBI_NO_PSD", "1");
    @cDefine("STBI_NO_PIC", "1");
    @cDefine("STBI_NO_PNM", "1");
    @cDefine("STBI_NO_STDIO", "1");
    @cInclude("vendor/stb_image.h");
});

// Embedded assets - provided by build.zig as a module
// const assets = @import("embedded_assets.zig");

fn image_from_memory(data: []const u8) Image {
    var x: c_int = undefined;
    var y: c_int = undefined;
    var channels_in_file: c_int = undefined;

    const raw = stbi.stbi_load_from_memory(data.ptr, @intCast(data.len), &x, &y, &channels_in_file, 4) orelse {
        @panic("Failed to load embedded image");
    };

    const pixels = @as(usize, @intCast(x)) * @as(usize, @intCast(y));
    const pixel_data: [*]u32 = @ptrCast(@alignCast(raw));

    for (0..pixels) |i| {
        const pixel = pixel_data[i];
        // stb: memory is R,G,B,A -> as u32 little-endian: 0xAABBGGRR
        // we need: 0xAARRGGBB
        const r = pixel & 0xFF;
        const g = (pixel >> 8) & 0xFF;
        const b = (pixel >> 16) & 0xFF;
        const a = (pixel >> 24) & 0xFF;
        pixel_data[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }

    return .{ .data = pixel_data[0..pixels], .w = @intCast(x), .h = @intCast(y) };
}

const sprite_data = init: {
    var map = std.EnumArray(SpriteKey, []const u8).initUndefined();

    for (std.enums.values(SpriteKey)) |key| {
        map.set(key, @embedFile("assets/" ++ @tagName(key) ++ ".png"));
    }

    break :init map;
};

pub fn load_sprites(storage: *SpriteStorage) void {
    for (std.enums.values(SpriteKey)) |sprite_key| {
        storage.images[@intFromEnum(sprite_key)] = image_from_memory(sprite_data.get(sprite_key));
    }
}

// levels

const level_data = blk: {
    var result = std.EnumArray(LevelKey, struct { bg: []const u8, fg: []const u8 }).initUndefined();
    for (std.enums.values(LevelKey)) |key| {
        result.set(key, .{
            .bg = @embedFile("assets/levels/" ++ @tagName(key) ++ "/bg.png"),
            .fg = @embedFile("assets/levels/" ++ @tagName(key) ++ "/fg.png"),
        });
    }
    break :blk result;
};

pub fn load_level(key: LevelKey) Level {
    const data = level_data.get(key);
    return .{
        .key = key,
        .bg = image_from_memory(data.bg),
        .fg = image_from_memory(data.fg),
    };
}

const things_data = blk: {
    var result = std.EnumArray(LevelKey, []const u8).initUndefined();
    for (std.enums.values(LevelKey)) |key| {
        result.set(key, @embedFile("assets/levels/" ++ @tagName(key) ++ "/things.bin"));
    }
    break :blk result;
};

pub fn load_level_things(key: LevelKey, things: *ThingPool) void {
    const data = things_data.get(key);
    const bytes = std.mem.asBytes(things);
    if (data.len == bytes.len) {
        @memcpy(bytes, data);
    }
}
