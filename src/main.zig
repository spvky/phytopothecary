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
    const texture = try rl.loadTexture("./assets/textures/cheffy_tex.png");
    const shader = try rl.loadShader("./assets/shaders/spiky.vs", "./assets/shaders/grayscale.fs");

    model.materials[0].shader = shader;
    model.materials[0].maps[0].texture = texture;

    const camera = rl.Camera3D{ .position = .{ .x = 0, .y = 0, .z = 10 }, .target = .{ .x = 0, .y = 0, .z = 0 }, .up = .{ .x = 0, .y = 1, .z = 0 }, .fovy = 45, .projection = .perspective };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        camera.begin();
        rl.clearBackground(rl.Color.dark_gray);
        rl.drawModel(model, .{ .x = 0, .y = 0, .z = 0 }, 1, rl.Color.white);
        camera.end();
        rl.endDrawing();
    }
}
