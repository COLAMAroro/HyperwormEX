// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later
//
// Hyperworm EX - Zig Port
// Main entry point

const std = @import("std");
const c = @import("const.zig");
const engine = @import("engine.zig");
const platform = @import("platform.zig");
const game_mod = @import("game.zig");
const tunnel = @import("tunnel.zig");

pub fn main() !void {
    std.debug.print("[GAME] Starting Hyperworm EX (Zig)...\n", .{});

    // Initialize platform
    var plat = try platform.init();
    defer plat.deinit();

    // Create render context
    var render = try engine.Render.init(c.SOFTWARE_WIDTH, c.SOFTWARE_HEIGHT);
    defer render.deinit();

    // Initialize color LUT
    std.debug.print("[GAME] Initializing color LUT...\n", .{});
    engine.lut.reset();

    // Initialize tunnel effect
    std.debug.print("[GAME] Initializing tunnel effect...\n", .{});
    tunnel.init();

    // Display loading message
    render.drawText("PRECACHING...", c.SOFTWARE_HEIGHT / 2 - 5);
    plat.renderBegin(&render);
    plat.renderEnd(&render);

    // Initialize game
    var game = try game_mod.Game.init(&render);
    defer game.deinit();

    std.debug.print("[GAME] Entering main loop...\n", .{});

    // Main game loop
    var running = true;
    while (running) {
        // Update platform (handle events, input)
        if (!plat.update(&render)) {
            break;
        }

        // Begin frame
        plat.renderBegin(&render);

        // Update game state
        running = game.update(&render, &plat);

        // End frame
        plat.renderEnd(&render);
    }

    std.debug.print("[GAME] Quitting.\n", .{});
}
