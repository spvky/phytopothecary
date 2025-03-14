const std = @import("std");
const rl = @import("raylib");
const physics = @import("physics.zig");
const World = @import("world.zig").World;

pub fn spawn_balls(world: *World) void {
    const t1: physics.Translation = .{ .translation = .{ .x = 2, .y = 2, .z = 0 } };
    const t2: physics.Translation = .{ .translation = .{ .x = 1, .y = 2, .z = 0 } };
    _ = world.spawn(.{ physics.Velocity, t1 });
    _ = world.spawn(.{ physics.Velocity, t2 });
}

pub fn update_balls(world: *World, delta: f32) void {
    var view = world.registry.view(.{physics.Translation}, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        var pos = view.get(entity);
        pos.translation.x += 1 * delta;
    }
}

pub fn draw_balls(world: *World) void {
    var view = world.registry.view(.{physics.Translation}, .{});
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

    const model = try rl.loadModel("./assets/models/cheffy.glb");
    const noise = try rl.loadTextureFromImage(rl.genImagePerlinNoise(1024, 1024, 50, 50, 4.0));
    const check = try rl.loadTexture("./assets/textures/check.png");
    const shader = try rl.loadShader("./assets/shaders/grass.glsl", null); // "./assets/shaders/grayscale.glsl");
    const grass_patch = try rl.loadModelFromMesh(rl.genMeshPlane(100, 100, 100, 100));

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
        const y_position = 0;
        rl.beginDrawing();
        camera.begin();
        rl.clearBackground(rl.Color.dark_gray);
        draw_balls(&world);
        rl.drawModel(model, .{ .x = 0, .y = y_position, .z = 0 }, 1, rl.Color.white);
        rl.drawModel(grass_patch, .{ .x = 0, .y = -3, .z = 0 }, 1, rl.Color.sky_blue);
        camera.end();
        rl.endDrawing();
    }
}
