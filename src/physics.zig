const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;

pub const Velocity = struct {
    velocity: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 },
};

pub const Translation = struct {
    translation: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 },
};
