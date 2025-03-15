const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;

const GRAVITY: rl.Vector3 = .{ .x = 0, .y = -9.81, .z = 0 };

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    const Self = @This();
    const default: Self = .{ .x = 0, .y = 0, .z = 0 };
    const X: Self = .{ .x = 1, .y = 0, .z = 0 };
    const Y: Self = .{ .x = 0, .y = 1, .z = 0 };
    const Z: Self = .{ .x = 0, .y = 0, .z = 1 };
    const NEG_X: Self = .{ .x = -1, .y = 0, .z = 0 };
    const NEG_Y: Self = .{ .x = 0, .y = -1, .z = 0 };
    const NEG_Z: Self = .{ .x = 0, .y = 0, .z = -1 };

    pub fn add(self: Self, rhs: Self) Self {
        return .{ .x = self.x + rhs.x, .y = self.y + rhs.y, .z = self.z + rhs.z };
    }
    pub fn sub(self: Self, rhs: Self) Self {
        return .{ .x = self.x - rhs.x, .y = self.y - rhs.y, .z = self.z - rhs.z };
    }
    pub fn mult(self: Self, rhs: Self) Self {
        return .{ .x = self.x * rhs.x, .y = self.y * rhs.y, .z = self.z * rhs.z };
    }
    pub fn scale(self: Self, value: f32) Self {
        return .{ .x = self.x * value, .y = self.y * value, .z = self.z * value };
    }
    pub fn divide(self: Self, value: f32) Self {
        return .{ .x = self.x / value, .y = self.y / value, .z = self.z / value };
    }
    pub fn neg(self: Self) Self {
        return .{ .x = self.x * -1, .y = self.y * -1, .z = self.z * -1 };
    }
    pub fn squared(self: Self) Self {
        return .{ .x = self.x * self.x, .y = self.y * self.y, .z = self.z * self.z };
    }
    pub fn length(self: Self) f32 {
        return std.math.sqrt(self.length_squared());
    }
    pub fn dist(self: Self, rhs: Self) f32 {
        return self.sub(rhs).length();
    }
    pub fn normalize(self: Self) Self {
        self.divide(self.length);
    }
    /// Returns the normalize direction of self facing rhs
    pub fn direction(self: Self, rhs: Self) Self {
        return rhs.sub(self).normalize();
    }
    pub fn to_rl(self: Self) rl.Vector3 {
        return .{ .x = self.x, .y = self.y, .z = self.z };
    }
};

pub const Rigidbody = struct {
    collider: Collider,
    rb_type: RigidbodyType,

    pub const RigidbodyType = enum { static, dynamic, kinematic };
    pub const ColliderTag = enum {
        sphere,
        cuboid,
    };

    pub const Collider = union(ColliderTag) { sphere: f32, cuboid: rl.Vector3 };
};

pub const Velocity = struct { velocity: Vec3 = .{ .x = 0, .y = 0, .z = 0 } };

pub const Transform = struct {
    translation: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 },
    scale: f32 = 1,
};

pub const IgnoreGravity = struct {};

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

pub fn dynamics(world: *World, delta: f32) void {
    apply_gravity(world, delta);
    dampen_velocity(world, delta);
    apply_velocity(world, delta);
}
