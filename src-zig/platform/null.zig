// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later
//
// Null backend - minimal testing platform

const std = @import("std");
const engine = @import("../engine.zig");

pub const Platform = struct {
    frame_count: u64,

    pub fn init() !Platform {
        std.debug.print("[PLATFORM] Initializing Null backend...\n", .{});
        return Platform{
            .frame_count = 0,
        };
    }

    pub fn deinit(self: *Platform) void {
        _ = self;
        std.debug.print("[PLATFORM] Shutting down...\n", .{});
    }

    pub fn update(self: *Platform, render: *engine.Render) bool {
        self.frame_count += 1;

        // Simulate fixed timestep
        render.dt = 0.016; // 60 FPS

        // Null backend runs indefinitely
        return true;
    }

    pub fn renderBegin(self: *Platform, render: *engine.Render) void {
        _ = self;
        render.clear();
    }

    pub fn renderEnd(self: *Platform, render: *engine.Render) void {
        _ = self;
        _ = render;
        // In null backend, nothing to present
    }
};
