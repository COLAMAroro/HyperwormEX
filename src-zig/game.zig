// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");
const engine = @import("engine.zig");

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
        _ = render;

        switch (self.state) {
            .init => {
                self.state = .menu;
            },
            .menu => {
                // Menu logic here
                self.state = .exit; // Exit after one frame for null backend
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
