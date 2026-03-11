const MenuState = @import("menus.zig").MenuState;
const ThingPool = @import("things.zig").ThingPool;
const ThingRef = @import("things.zig").ThingRef;
const Level = @import("level.zig").Level;

// const PortalCtx =

pub const EditorState = struct {
    menu: MenuState = .{},
    things: ThingPool = .{},
    level: ?Level = null,
    portal_dest_level: ?Level = null,
    portal_ref: ThingRef = ThingRef.nil(),
    cursor_x: i32 = 0,
    cursor_y: i32 = 0,
    camera_x: i32 = 0,
    camera_y: i32 = 0,
};
