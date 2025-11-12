// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");
const engine = @import("engine.zig");
const tunnel = @import("tunnel.zig");
const platform_mod = @import("platform.zig");
const build_options = @import("build_options");

pub const GameState = enum {
    init,
    menu,
    newgame,
    level,
    wormhole,
    lose,
    end,
    exit,
};

pub const Game = struct {
    state: GameState,
    round: i32,
    allocator: std.mem.Allocator,

    pub fn init(render: *engine.Render) !Game {
        _ = render;
        std.debug.print("[GAME] Initializing game...\n", .{});
        
        return Game{
            .state = .menu,
            .round = 0,
            .allocator = std.heap.c_allocator,
        };
    }

    pub fn deinit(self: *Game) void {
        _ = self;
        std.debug.print("[GAME] Cleaning up game...\n", .{});
    }

    pub fn update(self: *Game, render: *engine.Render, plat: *platform_mod.Platform) bool {
        switch (self.state) {
            .init => {
                self.state = .menu;
            },
            .menu => {
                // Draw tunnel effect background
                tunnel.draw(render);
                
                // Draw menu text
                render.drawText("HYPERWORM EX", 40);
                render.drawText("PRESS SPACE TO START", 120);
                render.drawText("PRESS Q TO QUIT", 135);
                
                // Check for input based on backend
                const backend_name = build_options.backend;
                
                // Check for SPACE key to start game
                if (std.mem.eql(u8, backend_name, "x11")) {
                    // X11 key codes (XK_space = 0x20, XK_q = 0x71)
                    if (plat.isKeyPressed(0x20)) {
                        self.state = .newgame;
                    }
                    if (plat.isKeyPressed(0x71)) {
                        self.state = .exit;
                    }
                } else if (std.mem.eql(u8, backend_name, "raylib")) {
                    // Raylib key codes (KEY_SPACE = 32, KEY_Q = 81)
                    if (plat.isKeyPressed(32)) {
                        self.state = .newgame;
                    }
                    if (plat.isKeyPressed(81)) {
                        self.state = .exit;
                    }
                }
            },
            .newgame => {
                self.round = 0;
                self.state = .level;
            },
            .level => {
                // Level logic here
            },
            .wormhole => {
                // Wormhole (upgrade) logic
            },
            .lose => {
                // Lose state
                self.state = .exit;
            },
            .end => {
                // End/win state
                self.state = .exit;
            },
            .exit => {
                return false;
            },
        }

        return self.state != .exit;
    }
};
