const std = @import("std");
const rl = @import("raylib");

pub const Vec2 = struct {
    x: f32,
    y: f32,

    const Self = @This();

    const default: Self = .{ .x = 0, .y = 0 };
    const ONE: Self = .{ .x = 1, .y = 1 };
    const X: Self = .{ .x = 1, .y = 0 };
    const Y: Self = .{ .x = 0, .y = 1 };
    const NEG_X: Self = .{ .x = 1, .y = 1 };
    const NEG_Y: Self = .{ .x = 0, .y = 1 };

    pub fn add(self: Self, rhs: Self) Self {
        return .{ .x = self.x + rhs.x, .y = self.y + rhs.y };
    }

    pub fn sub(self: Self, rhs: Self) Self {
        return .{ .x = self.x - rhs.x, .y = self.y - rhs.y };
    }

    pub fn mult(self: Self, rhs: Self) Self {
        return .{ .x = self.x * rhs.x, .y = self.y * rhs.y };
    }

    pub fn scale(self: Self, value: f32) Self {
        return .{ .x = self.x * value, .y = self.y * value };
    }
};

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    const Self = @This();
    const default: Self = .{ .x = 0, .y = 0, .z = 0 };
    const ONE: Self = .{ .x = 1, .y = 1, .z = 1 };
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
    pub fn length_squared(self: Self) f32 {
        return std.math.pow(f32, self.x, 2) + std.math.pow(f32, self.y, 2) + std.math.pow(f32, self.z, 2);
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

pub const Quat = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub const identity: @This() = .{ .x = 0, .y = 0, .z = 0, .w = 0 };

    // q = w1 + xi + yj + zk
    // w is the scale of the quaternion, and xyz define the axis,
    // because of this the x,y,z components of quaternions are not really that useful on their own, because they define an arbitrary axis (x,y,z) rotated by w radians
    //
    // i^2 = j^2 = k^2 = -1
};
