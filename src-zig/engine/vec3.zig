// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later

const std = @import("std");
const math = std.math;
const utils = @import("utils.zig");

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub inline fn add(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    pub inline fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }

    pub inline fn muls(a: Vec3, s: f32) Vec3 {
        return .{
            .x = a.x * s,
            .y = a.y * s,
            .z = a.z * s,
        };
    }

    pub inline fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub inline fn length(a: Vec3) f32 {
        return @sqrt(dot(a, a));
    }

    pub inline fn lengthSquared(a: Vec3) f32 {
        return dot(a, a);
    }

    pub inline fn normalize(a: Vec3) Vec3 {
        const len = length(a);
        if (len > 1e-6) {
            return muls(a, 1.0 / len);
        }
        return .{ .x = 0.0, .y = 0.0, .z = 0.0 };
    }

    pub inline fn distance(a: Vec3, b: Vec3) f32 {
        return length(sub(a, b));
    }

    pub fn moveTo(a: Vec3, b: Vec3, step: f32) Vec3 {
        const vd = sub(b, a);
        const len = length(vd);

        if (len < step or len < 1e-6) {
            return b;
        }

        return add(a, muls(vd, step / len));
    }

    // Framerate-independent lerp (Freya's method)
    pub fn lerp(a: Vec3, b: Vec3, decay: f32, dt: f32) Vec3 {
        const exp = @exp(-decay * dt);
        return .{
            .x = b.x + (a.x - b.x) * exp,
            .y = b.y + (a.y - b.y) * exp,
            .z = b.z + (a.z - b.z) * exp,
        };
    }

    pub fn random(scale: f32) Vec3 {
        return .{
            .x = utils.randf(-scale, scale),
            .y = utils.randf(-scale, scale),
            .z = utils.randf(-scale, scale),
        };
    }

    // Get the angle between 2 vectors (XZ plane)
    pub fn angle(a: Vec3, b: Vec3) f32 {
        const cross = a.x * b.z - a.z * b.x;
        const dot_val = a.x * b.x + a.z * b.z;
        return math.atan2(cross, dot_val);
    }
};
