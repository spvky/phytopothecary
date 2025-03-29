const std = @import("std");
const rl = @import("raylib");
const physics = @import("physics.zig");
const World = @import("world.zig").World;
const ModelTag = @import("world.zig").ModelTag;
const rendering = @import("rendering.zig");
const player = @import("player.zig");

comptime {
    _ = @import("test.zig");
}

pub fn main() !void {
    var world = try World.init(std.heap.page_allocator);
    defer world.deinit();

    // Load Models
    var grass = try rl.loadModelFromMesh(rl.genMeshPlane(10, 10, 100, 100));
    var road = try rl.loadModelFromMesh(rl.genMeshPlane(15, 100, 250, 250));
    var player_model = try rl.loadModel("./assets/models/cheffy.glb");

    var grass_shader = try rl.loadShader("./assets/shaders/grass.glsl", null);
    var road_shader = try rl.loadShader("./assets/shaders/wavy_road.glsl", "./assets/shaders/road_color.glsl");

    try world.store_model(.grass, &grass);
    try world.store_model(.road, &road);
    try world.store_model(.player, &player_model);

    try world.store_shader(.grass, &grass_shader);
    try world.store_shader(.road, &road_shader);

    world.map_shaders();

    const player_id = world.spawn(.{ player.Player, physics.Transform{ .translation = .{ .x = 3, .y = 0, .z = 0 } }, rendering.Model{ .model = &player_model } });
    _ = player_id;

    const road_id = world.spawn(.{ physics.Transform{ .translation = .{ .x = 0, .y = 0, .z = 0 } }, rendering.Model{ .model = &road } });
    _ = road_id;

    // const noise = try rl.loadTextureFromImage(rl.genImagePerlinNoise(1024, 1024, 50, 50, 4.0));
    // const check = try rl.loadTexture("./assets/textures/check.png");
    // grass_patch.materials[0].maps[0].texture = noise;
    // grass_patch.materials[0].maps[1].texture = check;

    // End model and shader stuff

    try world.startup();

    while (!rl.windowShouldClose()) {
        world.update();
        player.player_shader_update(&world);
        world.draw();
    }
}
