const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");
const rendering = @import("rendering.zig");

pub const ShaderTag = enum { grass, road };
pub const ModelTag = enum { grass, road, player };

const ShaderMap = std.AutoArrayHashMapUnmanaged(ShaderTag, rl.Shader);
const ModelMap = std.AutoArrayHashMapUnmanaged(ModelTag, rl.Model);

pub const World = struct {
    main_camera: rl.Camera,
    registry: ecs.Registry,
    allocator: std.mem.Allocator,
    shaders: ShaderMap,
    models: ModelMap,

    const Self = @This();

    const ZERO_VEC: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 };

    pub fn init(allocator: std.mem.Allocator) !Self {
        const camera = rl.Camera3D{ .position = .{ .x = 0, .y = 4, .z = -8 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };
        const registry = ecs.Registry.init(allocator);
        const shaders: ShaderMap = .empty;
        const models: ModelMap = .empty;
        raylib_init();

        return .{ .registry = registry, .allocator = allocator, .main_camera = camera, .shaders = shaders, .models = models };
    }

    pub fn raylib_init() void {
        var WINDOW_WIDTH: i32 = 1600;
        var WINDOW_HEIGHT: i32 = 900;
        rl.setConfigFlags(.{ .window_resizable = true });
        rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "phytopothecary");
        const monitor = rl.getCurrentMonitor();
        WINDOW_WIDTH = rl.getMonitorWidth(monitor);
        WINDOW_HEIGHT = rl.getMonitorHeight(monitor);
    }

    pub fn map_shaders(self: *Self) void {
        var iter = self.models.iterator();
        while (iter.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr;
            const material_count: usize = @intCast(value.materialCount);
            const shader_opt: ?rl.Shader = switch (key) {
                ModelTag.grass => self.shaders.get(ShaderTag.grass).?,
                ModelTag.road => self.shaders.get(ShaderTag.road).?,
                else => null,
            };

            if (shader_opt) |shader| {
                for (0..material_count) |i| {
                    value.*.materials[i].shader = shader;
                }
            }
        }
    }

    pub fn store_model(self: *Self, tag: ModelTag, model: *rl.Model) !void {
        try self.models.put(self.allocator, tag, model.*);
    }

    pub fn store_shader(self: *Self, tag: ShaderTag, shader: *rl.Shader) !void {
        try self.shaders.put(self.allocator, tag, shader.*);
    }

    pub fn set_shader_time(self: *Self) void {
        const time: f32 = @floatCast(rl.getTime());
        var iter = self.shaders.iterator();
        while (iter.next()) |shader| {
            const time_loc = rl.getShaderLocation(shader.value_ptr.*, "time");
            rl.setShaderValue(shader.value_ptr.*, time_loc, &time, .float);
        }
    }

    pub fn deinit(self: *Self) void {
        self.registry.deinit();
        rl.closeWindow();
    }

    pub fn update(self: *Self) void {
        self.set_shader_time();
    }

    pub fn draw(self: *Self) void {
        rl.beginDrawing();
        self.main_camera.begin();
        rl.clearBackground(rl.Color.dark_gray);
        rendering.draw_models(self);
        self.main_camera.end();
        rl.endDrawing();
    }

    pub fn spawn(self: *Self, components: anytype) ecs.Entity {
        const entity = self.registry.create();
        if (components.len > 0) {
            inline for (components) |component| {
                switch (@typeInfo(@TypeOf(component))) {
                    .type => self.registry.add(entity, std.mem.zeroes(component)),
                    else => self.registry.add(entity, component),
                }
            }
        }
        return entity;
    }
};
