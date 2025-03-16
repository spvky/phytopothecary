const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;

const GRAVITY: rl.Vector3 = .{ .x = 0, .y = -9.81, .z = 0 };

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

pub const Velocity = struct { velocity: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 } };

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
