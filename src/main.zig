const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs");

pub fn main() !void {
    var WINDOW_WIDTH: i32 = 1600;
    var WINDOW_HEIGHT: i32 = 900;
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "phytopothecary");
    const monitor = rl.getCurrentMonitor();
    WINDOW_WIDTH = rl.getMonitorWidth(monitor);
    WINDOW_HEIGHT = rl.getMonitorHeight(monitor);
    defer rl.closeWindow();

    const model = try rl.loadModel("./assets/models/cheffy.glb");
    const noise = try rl.loadTextureFromImage(rl.genImagePerlinNoise(512, 512, 50, 50, 4.0));
    const shader = try rl.loadShader("./assets/shaders/grass.glsl", null);
    const grass_patch = try rl.loadModelFromMesh(rl.genMeshPlane(20, 20, 100, 100));

    const material_count: usize = @intCast(grass_patch.materialCount);
    for (0..material_count) |i| {
        grass_patch.materials[i].shader = shader;
        grass_patch.materials[i].maps[i].texture = noise;
    }
    const time_loc = rl.getShaderLocation(shader, "time");
    const noise_loc = rl.getShaderLocation(shader, "noise");

    const camera = rl.Camera3D{ .position = .{ .x = 0, .y = 4, .z = -8 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };

    while (!rl.windowShouldClose()) {
        const time: f32 = @floatCast(rl.getTime());
        const time_wobble = std.math.sin(time * 10.0) * 0.3;
        rl.setShaderValue(shader, noise_loc, &noise, .sampler2d);
        rl.setShaderValue(shader, time_loc, &time, .float);
        _ = time_wobble;
        const y_position = 0;
        rl.beginDrawing();
        camera.begin();
        rl.clearBackground(rl.Color.dark_gray);
        rl.drawModel(model, .{ .x = 0, .y = y_position, .z = 0 }, 1, rl.Color.white);
        rl.drawModel(grass_patch, .{ .x = 0, .y = -3, .z = 0 }, 1, rl.Color.green);
        camera.end();
        rl.endDrawing();
    }
}
