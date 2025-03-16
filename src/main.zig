const std = @import("std");
const rl = @import("raylib");
const physics = @import("physics.zig");
const rendering = @import("rendering.zig");
const World = @import("world.zig").World;

pub const Player = struct {};

pub fn player_shader_stuff(world: *World, shader: rl.Shader) void {
    const loc = rl.getShaderLocation(shader, "playerPos");
    var view = world.registry.view(.{ physics.Transform, Player }, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        const transform = view.getConst(physics.Transform, entity);
        rl.setShaderValue(shader, loc, &transform.translation, .vec3);
    }
}
pub fn spawn_balls(world: *World) void {
    const t1: physics.Transform = .{ .translation = .{ .x = 2, .y = 2, .z = 0 } };
    const t2: physics.Transform = .{ .translation = .{ .x = 1, .y = 2, .z = 0 } };
    _ = world.spawn(.{ physics.Velocity, t1 });
    _ = world.spawn(.{ physics.Velocity, t2 });
}

pub fn update_balls(world: *World, delta: f32) void {
    var view = world.registry.view(.{physics.Transform}, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        var pos = view.get(entity);
        pos.translation.z += 0.5 * delta;
    }
}
pub fn draw_balls(world: *World) void {
    var view = world.registry.view(.{physics.Transform}, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        const pos = view.getConst(entity);
        rl.drawSphere(pos.translation, 1, rl.Color.red);
    }
}

pub fn main() !void {
    var world = World.init(std.heap.page_allocator);
    spawn_balls(&world);
    var WINDOW_WIDTH: i32 = 1600;
    var WINDOW_HEIGHT: i32 = 900;
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "phytopothecary");
    const monitor = rl.getCurrentMonitor();
    WINDOW_WIDTH = rl.getMonitorWidth(monitor);
    WINDOW_HEIGHT = rl.getMonitorHeight(monitor);
    defer rl.closeWindow();

    var model = try rl.loadModel("./assets/models/cheffy.glb");

    const player_id = world.spawn(.{ Player, physics.Transform{ .translation = .{ .x = 3, .y = 0, .z = 0 } }, rendering.Model{ .model = &model } });
    _ = player_id;
    const noise = try rl.loadTextureFromImage(rl.genImagePerlinNoise(1024, 1024, 50, 50, 4.0));
    const check = try rl.loadTexture("./assets/textures/check.png");
    const shader = try rl.loadShader("./assets/shaders/grass.glsl", null);
    const grass_patch = try rl.loadModelFromMesh(rl.genMeshPlane(10, 10, 100, 100));

    const material_count: usize = @intCast(grass_patch.materialCount);
    for (0..material_count) |i| {
        grass_patch.materials[i].shader = shader;
    }
    grass_patch.materials[0].maps[0].texture = noise;
    grass_patch.materials[0].maps[1].texture = check;

    const time_loc = rl.getShaderLocation(shader, "time");

    const camera = rl.Camera3D{ .position = .{ .x = 0, .y = 4, .z = -8 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };

    while (!rl.windowShouldClose()) {
        const delta = rl.getFrameTime();
        update_balls(&world, delta);
        const time: f32 = @floatCast(rl.getTime());
        rl.setShaderValue(shader, time_loc, &time, .float);
        player_shader_stuff(&world, shader);
        rl.beginDrawing();
        camera.begin();
        rl.clearBackground(rl.Color.dark_gray);
        rendering.draw_models(&world);
        rl.drawModel(grass_patch, .{ .x = 0, .y = -3, .z = 0 }, 1, rl.Color.sky_blue);
        camera.end();
        rl.endDrawing();
    }
}
