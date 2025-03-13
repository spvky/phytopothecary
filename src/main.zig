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
    const noise = try rl.loadTexture("./assets/textures/noise.png");
    const shader = try rl.loadShader("./assets/shaders/spiky.glsl", "./assets/shaders/grayscale.fs");

    const material_count: usize = @intCast(model.materialCount);
    for (0..material_count) |i| {
        model.materials[i].shader = shader;
    }
    const time_loc = rl.getShaderLocation(shader, "time");
    const noise_loc = rl.getShaderLocation(shader, "noise");

    const camera = rl.Camera3D{ .position = .{ .x = 0, .y = 0, .z = -8 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };

    while (!rl.windowShouldClose()) {
        const time: f32 = @floatCast(rl.getTime());
        const time_wobble = std.math.sin(time * 10.0) * 0.3;
        rl.setShaderValue(shader, time_loc, &time, .float);
        rl.setShaderValue(shader, noise_loc, &noise, .float);
        _ = time_wobble;
        const y_position = 0;
        rl.beginDrawing();
        camera.begin();
        rl.clearBackground(rl.Color.dark_gray);
        rl.drawModel(model, .{ .x = 0, .y = y_position, .z = 0 }, 1, rl.Color.white);
        camera.end();
        rl.endDrawing();
    }
}
