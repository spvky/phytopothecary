const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;

const GRAVITY: rl.Vector3 = .{ .x = 0, .y = -9.81, .z = 0 };

pub const Rigidbody = struct {
    collider: Collider = .{ .cuboid = .{ .x = 1, .y = 1, .z = 1 } },
    rb_type: RigidbodyType = .static,

    const Self = @This();
    pub const default = Self{ .collider = .{ .cuboid = .{ .x = 1, .y = 1, .z = 1 } }, .rb_type = .static };

    pub const RigidbodyType = enum { static, dynamic, kinematic };
    pub const ColliderTag = enum {
        sphere,
        cuboid,
    };

    pub const Collider = union(ColliderTag) { sphere: f32, cuboid: rl.Vector3 };

    pub fn DetectCollision(self: Self, self_transform: Transform, rhs: Self, rhs_transform: Transform) bool {
        const center = self_transform.translation;
        const r_center = rhs_transform.translation;
        switch (self.collider) {
            .sphere => |radius| {
                switch (rhs.collider) {
                    .sphere => |r_radius| {
                        return (center.distance(r_center) <= radius + r_radius);
                    },
                    .cuboid => |r_extents| {
                        var dmin: f32 = 0;
                        const r_half_extents = r_extents.scale(0.5);
                        const r_min = rhs_transform.translation.subtract(r_half_extents);
                        const r_max = rhs_transform.translation.add(r_half_extents);

                        if (center.x < r_min.x) {
                            dmin += std.math.pow(f32, center.x - r_min.x, 2);
                        } else if (center.x > r_max.x) {
                            dmin += std.math.pow(f32, center.x - r_max.x, 2);
                        }
                        if (center.y < r_min.y) {
                            dmin += std.math.pow(f32, center.y - r_min.y, 2);
                        } else if (center.y > r_max.y) {
                            dmin += std.math.pow(f32, center.y - r_max.y, 2);
                        }
                        if (center.z < r_min.z) {
                            dmin += std.math.pow(f32, center.z - r_min.z, 2);
                        } else if (center.z > r_max.z) {
                            dmin += std.math.pow(f32, center.z - r_max.z, 2);
                        }
                        return (dmin <= radius * radius);
                    },
                }
                return false;
            },
            .cuboid => |extents| {
                const half_extents = extents.scale(0.5);
                const min = self_transform.translation.subtract(half_extents);
                const max = self_transform.translation.add(half_extents);

                switch (rhs.collider) {
                    .sphere => |r_radius| {
                        var dmin: f32 = 0;
                        if (r_center.x < min.x) {
                            dmin += std.math.pow(f32, r_center.x - min.x, 2);
                        } else if (r_center.x > max.x) {
                            dmin += std.math.pow(f32, r_center.x - max.x, 2);
                        }
                        if (r_center.y < min.y) {
                            dmin += std.math.pow(f32, r_center.y - min.y, 2);
                        } else if (r_center.y > max.y) {
                            dmin += std.math.pow(f32, r_center.y - max.y, 2);
                        }
                        if (r_center.z < min.z) {
                            dmin += std.math.pow(f32, r_center.z - min.z, 2);
                        } else if (r_center.z > max.z) {
                            dmin += std.math.pow(f32, r_center.z - max.z, 2);
                        }
                        return (dmin <= r_radius * r_radius);
                    },
                    .cuboid => |r_extents| {
                        const r_half_extents = r_extents.scale(0.5);
                        const r_min = rhs_transform.translation.subtract(r_half_extents);
                        const r_max = rhs_transform.translation.add(r_half_extents);

                        if (max.x >= r_min.x and min.x <= r_max.x) {
                            if (max.y < r_min.y or min.y > r_max.y) return false;
                            if (max.z < r_min.z or min.z > r_max.z) return false;
                            return true;
                        }
                    },
                }
            },
        }
        return false;
    }
};

test "AABB collision" {
    const a: Rigidbody = .default;
    const b: Rigidbody = .default;
    const c: Rigidbody = .default;
    const a_t: Transform = .{ .translation = .{ .x = 0, .y = 0, .z = 0 } };
    const b_t: Transform = .{ .translation = .{ .x = 0.5, .y = 0.5, .z = 0 } };
    const c_t: Transform = .{ .translation = .{ .x = 3.0, .y = 0.5, .z = 0 } };

    try std.testing.expect(a.DetectCollision(a_t, b, b_t));
    try std.testing.expect(!a.DetectCollision(a_t, c, c_t));
}

pub const Velocity = struct { velocity: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 } };

pub const Transform = struct {
    translation: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 },
    scale: f32 = 1,
};

pub const IgnoreGravity = struct {};
pub const Grounded = struct {};
pub const Platform = struct {};

pub const Dampening = f32;

pub const Collision = struct {
    const ecs = @import("ecs").Entity;
    a: ecs.Entity,
    b: ecs.Entity,
    normal: rl.Vector3,
    depth: f32,
};

pub fn dampen_velocity(world: *World, delta: f32) void {
    var view = world.registry.view(.{ Velocity, Rigidbody, Dampening });
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        var velo = view.get(Velocity, entity);
        const dampening = view.getConst(Dampening, entity);
        const dampen_amount = velo.velocity.scale(1 / dampening);
        velo.subtract(dampen_amount.scale(delta));
    }
}

pub fn apply_gravity(world: *World, delta: f32) void {
    var view = world.registry.view(.{Velocity}, .{IgnoreGravity});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        var velo = view.get(Velocity, entity);
        velo.velocity.add(GRAVITY.scale(delta));
    }
}

pub fn apply_velocity(world: *World, delta: f32) void {
    var view = world.registry.view(.{ Velocity, Transform, Rigidbody }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const rb = view.getConst(Rigidbody, entity);
        const velo = view.getConst(Velocity, entity);
        var translation = view.get(Transform, entity);

        switch (rb.rb_type) {
            .static => {},
            else => {
                translation.translation.add(velo.scale(delta));
            },
        }
    }
}

pub fn snap_to_ground(world: *World, delta: f32) void {
    // Look for prospective collisions with platforms
    // if one is found position the rigidbody so that it is on the ground
    const view = world.registry.view(.{ Velocity, Transform, Rigidbody }, .{});
    _ = view;
    _ = delta;
}

pub fn dynamics(world: *World, delta: f32) void {
    apply_gravity(world, delta);
    dampen_velocity(world, delta);
    apply_velocity(world, delta);
}
