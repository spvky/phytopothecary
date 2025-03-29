const rl = @import("raylib");
const World = @import("world.zig").World;
const physics = @import("physics.zig");

pub const Player = struct {};

pub fn player_shader_update(world: *World) void {
    const road_shader_opt = world.shaders.get(.road);

    if (road_shader_opt) |shader| {
        const loc = rl.getShaderLocation(shader, "playerPos");
        var view = world.registry.view(.{ physics.Transform, Player }, .{});
        var iter = view.entityIterator();

        while (iter.next()) |entity| {
            const transform = view.getConst(physics.Transform, entity);
            rl.setShaderValue(shader, loc, &transform.translation, .vec3);
        }
    }
}
