// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");
const math = std.math;

// Color conversion for little endian
pub inline fn rgba2u32(r: u8, g: u8, b: u8, a: u8) u32 {
    return (@as(u32, a) << 24) | (@as(u32, b) << 16) | (@as(u32, g) << 8) | @as(u32, r);
}

// Framerate-independent lerp (Freya's method)
// Decay: useful range 1-25, from slow to fast
pub inline fn lerpf(a: f32, b: f32, decay: f32, dt: f32) f32 {
    return b + (a - b) * @exp(-decay * dt);
}

pub inline fn min(comptime T: type, a: T, b: T) T {
    return if (a <= b) a else b;
}

pub inline fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

pub inline fn clampf(x: f32, min_val: f32, max_val: f32) f32 {
    if (x < min_val) return min_val;
    if (x > max_val) return max_val;
    return x;
}

// Random number state (global for simplicity, matching C version)
var rng_state: std.Random.DefaultPrng = undefined;
var rng_initialized: bool = false;

pub fn initRng(seed: u64) void {
    rng_state = std.Random.DefaultPrng.init(seed);
    rng_initialized = true;
}

pub fn getRng() std.Random {
    if (!rng_initialized) {
        initRng(@intCast(std.time.milliTimestamp()));
    }
    return rng_state.random();
}

pub fn randi(a: i32, b: i32) i32 {
    if (a == b) return a;
    const range: u32 = @intCast(b - a);
    return a + @as(i32, @intCast(getRng().intRangeAtMost(u32, 0, range - 1)));
}

pub fn randf(a: f32, b: f32) f32 {
    return a + getRng().float(f32) * (b - a);
}

pub fn coinflip() bool {
    return getRng().int(u1) == 1;
}
