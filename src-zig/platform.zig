// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later
//
// Platform abstraction layer - Backend selection at compile time

const std = @import("std");
const engine = @import("engine.zig");
const build_options = @import("build_options");

// Select platform backend at compile time
const backend_name = build_options.backend;

const Backend = if (std.mem.eql(u8, backend_name, "x11"))
    @import("platform/x11.zig")
else if (std.mem.eql(u8, backend_name, "raylib"))
    @import("platform/raylib.zig")
else
    @import("platform/null.zig");

pub const Platform = Backend.Platform;

pub fn init() !Platform {
    return Platform.init();
}
