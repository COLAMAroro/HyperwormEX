// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");
const engine = @import("engine.zig");
const tunnel = @import("tunnel.zig");

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

    pub fn update(self: *Game, render: *engine.Render) bool {
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
                
                // Menu logic - stay in menu until player input triggers state change
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
