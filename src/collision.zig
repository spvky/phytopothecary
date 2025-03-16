const std = @import("std");
const Vec2 = @import("math.zig").Vec2;

pub const Box = struct {
    center: Vec2,
    extents: Vec2,
    pub fn new(cx: f32, cy: f32, ex: f32, ey: f32) @This() {
        return .{
            .center = .{ .x = cx, .y = cy },
            .extents = .{ .x = ex, .y = ey },
        };
    }

    // pub collide_with_circle(self: @This(), circle: Circle) bool {

    // }
};

pub const Circle = struct {
    center: Vec2,
    radius: f32,

    pub fn new(c: Vec2, r: f32) @This() {
        return .{ .center = c, .radius = r };
    }
};
