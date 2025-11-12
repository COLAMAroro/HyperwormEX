// Copyright (c) 2025 SheatNoisette & HeraldOD
// Licensed under GPLv3 or later
//
// Tunnel effect for menu/transitions

const std = @import("std");
const c = @import("const.zig");
const engine = @import("engine.zig");

// Tunnel configuration
pub const TUNNEL_ROTATION: f32 = 1.0;
pub const TUNNEL_SPEED: f32 = 30.0;
pub const TUNNEL_TEX_SIZE: usize = 80;
pub const TUNNEL_COLOR: u32 = 0xB06050;
pub const TUNNEL_LENGTH: f32 = 12.0;
pub const TUNNEL_SPARSENESS: u32 = 300;
pub const TUNNEL_DARKNESS: f32 = 0.5;

const M_2_PI: f32 = 2.0 * std.math.pi;

// Pre-computed lookup tables
var texture_tunnel: [TUNNEL_TEX_SIZE * TUNNEL_TEX_SIZE]u32 = undefined;
var distance_map: [c.SOFTWARE_WIDTH * c.SOFTWARE_HEIGHT]f32 = undefined;
var angle_map: [c.SOFTWARE_WIDTH * c.SOFTWARE_HEIGHT]f32 = undefined;
var tunnel_tick: f32 = 0.0;

pub fn init() void {
    tunnel_tick = 0.0;

    // Build tunnel texture with random stars
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.milliTimestamp()));
    const random = rng.random();

    for (0..TUNNEL_TEX_SIZE) |ty| {
        for (0..TUNNEL_TEX_SIZE) |tx| {
            const is_star = random.intRangeAtMost(u32, 0, TUNNEL_SPARSENESS - 1) == 0;
            texture_tunnel[ty * TUNNEL_TEX_SIZE + tx] = if (is_star) TUNNEL_COLOR else 0x000000;
        }
    }

    // Pre-compute distance and angle maps
    for (0..c.SOFTWARE_HEIGHT) |y| {
        for (0..c.SOFTWARE_WIDTH) |x| {
            const index = y * c.SOFTWARE_WIDTH + x;
            const dx = @as(f32, @floatFromInt(x)) - (@as(f32, @floatFromInt(c.SOFTWARE_WIDTH)) / 2.0);
            const dy = @as(f32, @floatFromInt(y)) - (@as(f32, @floatFromInt(c.SOFTWARE_HEIGHT)) / 2.0);

            // Distance from center
            distance_map[index] = @sqrt(dx * dx + dy * dy);
            // Angle relative to center [-PI to +PI]
            angle_map[index] = std.math.atan2(dy, dx);
        }
    }
}

pub fn draw(render: *engine.Render) void {
    tunnel_tick += render.dt;

    // Rotation and speed offsets
    const time_offset_angle = tunnel_tick * TUNNEL_ROTATION;
    const time_offset_dist = tunnel_tick * TUNNEL_SPEED;

    for (0..c.SOFTWARE_HEIGHT) |y| {
        for (0..c.SOFTWARE_WIDTH) |x| {
            const screen_index = y * c.SOFTWARE_WIDTH + x;
            const dist = distance_map[screen_index];
            const angle = angle_map[screen_index];

            // Avoid division by zero at exact center
            if (dist < 0.01) {
                render.frame_buffer[screen_index] = 0;
                continue;
            }

            // Angle to texture U coordinate
            const u_raw = (angle / M_2_PI + 0.5) * @as(f32, @floatFromInt(TUNNEL_TEX_SIZE)) - 
                         time_offset_angle * (@as(f32, @floatFromInt(TUNNEL_TEX_SIZE)) / M_2_PI);

            // Distance to texture V coordinate
            const v_raw = (@as(f32, @floatFromInt(TUNNEL_TEX_SIZE)) * TUNNEL_LENGTH / dist) + time_offset_dist;

            // Wrap coordinates with proper modulo
            const u_int: i32 = @intFromFloat(u_raw);
            const v_int: i32 = @intFromFloat(v_raw);
            
            const u: usize = @intCast(@mod(@mod(u_int, @as(i32, @intCast(TUNNEL_TEX_SIZE))) + @as(i32, @intCast(TUNNEL_TEX_SIZE)), @as(i32, @intCast(TUNNEL_TEX_SIZE))));
            const v: usize = @intCast(@mod(@mod(v_int, @as(i32, @intCast(TUNNEL_TEX_SIZE))) + @as(i32, @intCast(TUNNEL_TEX_SIZE)), @as(i32, @intCast(TUNNEL_TEX_SIZE))));

            const tex_color = texture_tunnel[v * TUNNEL_TEX_SIZE + u];

            // Apply darkness based on distance
            var darkness_factor = dist / (@as(f32, @floatFromInt(c.SOFTWARE_WIDTH)) * TUNNEL_DARKNESS);
            darkness_factor = engine.utils.clampf(darkness_factor, 0.01, 1.0);

            const r: u8 = @intFromFloat(@as(f32, @floatFromInt((tex_color >> 16) & 0xFF)) * darkness_factor);
            const g: u8 = @intFromFloat(@as(f32, @floatFromInt((tex_color >> 8) & 0xFF)) * darkness_factor);
            const b: u8 = @intFromFloat(@as(f32, @floatFromInt(tex_color & 0xFF)) * darkness_factor);

            render.frame_buffer[screen_index] = (@as(u32, r) << 16) | (@as(u32, g) << 8) | b;
        }
    }
}
